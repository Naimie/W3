-module(ring).
-compile(export_all).

test()->
  12 = start(3,4),
  hooray.

%I'm assuming I should start N processes and send the first message to the first process that sends a message to the second process and so on
start(N,M)->
  %spawn the parent function
  Parent = spawn(fun()-> p_loop() end),
  %call the create function to create N processes
  Pids = create_ps(N,[]),
  io:format("Pids: ~p~n",[Pids]),
  %find the first element in the list of processes
  Child = lists:nth(1,Pids),
  %send the first message of = to the first process in the ring
  Child ! {self(),{Parent,{0,M,Pids}}}.
  %p_loop(0).

%creates N processes and reverses the list returned so it's in the correct order
 create_ps(0,Pids) ->
   lists:reverse(Pids);
 create_ps(N, Pids)->
  Pid =spawn(fun() -> c_loop() end),
    create_ps(N-1,[Pid|Pids]).


%parent loop
p_loop()->
  receive
    {_From, {X, Pids}}->
      %io:format("in Parent loop: ~p~n",[X]),
      X,
      lists:foreach(fun(Y) -> exit(Y,kill) end, Pids),
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%does not return to start
      io:format("~p~n",[X]),
      % Cmd=X,
      % Cmd,
      p_loop()

  end.

%child process loop
c_loop()->
  receive
    %if M = 0 no messages will be sent
    {_From,{_Parent,{_I, 0, _Pids}}} ->
      io:format("No messages sent due to 0 laps"),
      c_loop();
    %message received by the first process
    {_From, {Parent,{0, M, Pids}}} ->
      Self = self(),
      io:format("First pid = ~p~n",[Self]),
      I = 1,
      %next process in the list found and message sent
      Next_Pid = lists:nth(I+1,Pids),
      Next_Pid ! {self(),{Parent,{I,M,Pids}}},
      c_loop();
    %general case message
    {_From, {Parent,{I, M, Pids}}} ->
      Self = self(),
      io:format("In Pid ~p~n",[Self]),
      Last = lists:last(Pids),

      %checks if the process receiving the message is the last process in the list
      if
        Self == Last  ->
        % io:format("In Pid ~p~n",[Self]),
        %decrements M as one lap is complete
        M2 = M-1,
          if
            %if M is now 0 the laps are complete and the final message including the N*M result is sent off to the parent
            M2 ==0 ->
            X = I+1*M,
            Parent ! {Self,{X,Pids}};
            true ->
             %if M =!= 0 more laps are needed and a message is sent to the first process in the list to start the new lap
             First = lists:nth(1,Pids),
             First ! {self(),{Parent,{I+1,M2,Pids}}},
             c_loop()
          end;
        %if the process is not the last process in the list
        true ->
          I2 = I+1,
          if
            %if more than one lap has been run finding the next list element is more involved than on the first lap
            I2 > length(Pids) ->
            Pos = I2 rem length(Pids),
              Next_Pid = lists:nth(Pos+1,Pids),
              Next_Pid ! {self(),{Parent,{I2,M,Pids}}},
              c_loop();
              true ->
              Next_Pid = lists:nth(I2+1,Pids),
              Next_Pid ! {self(),{Parent,{I2,M,Pids}}},
              c_loop()
          end

      end
  end.