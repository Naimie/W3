-module(ring).
-compile(export_all).

test()->
  %correct tests
  12 = start(3,4),
  800 = start(20,40),
  1 = start(1,1),

  %incorrect tests
  {'EXIT', _} = (catch start(0,2)),
  hooray.

%I'm assuming I should first start N processes and then send the first message to the first process that sends a message to the second process and so on.
start(N,M)->
  %reference to self
  S = self(),
  %spawn the parent loop function
  Parent = spawn(fun()-> p_loop(S) end),
  %call the create function to create N processes
  Pids = create_ps(N,[]),
  %find the first element in the list of processes
  Child = lists:nth(1,Pids),
  %send the first message of 0 to the first process in the ring
  Child ! {Parent,{0,M,Pids}},

  %receive the return value for start(N,M)
  receive
  X ->
    X
  end.

%creates N processes and reverses the list returned so it's in the correct order
 create_ps(0,Pids) ->
   lists:reverse(Pids);
 create_ps(N, Pids)->
  Pid =spawn(fun() -> c_loop() end),
    create_ps(N-1,[Pid|Pids]).


%parent loop
p_loop(S)->
  %receives the value of N*M from the final child process
  receive
    {X, Pids}->
      %makes sure all children are dead
      lists:foreach(fun(Y) -> exit(Y,kill) end, Pids),
      %send a message to self
      S ! X
  end.

%child process loop
c_loop()->
  receive
    %if M = 0 no messages will be sent
    {_Parent,{_I, 0, _Pids}} ->
      io:format("No messages sent due to 0 laps"),
      c_loop();
    %message received by the first process
    {Parent,{0, M, Pids}} ->
      I = 1,
      %next process in the list found and message sent
      if
     %checks if there is only one process
        length(Pids)>1 ->
        %if there are several processes it sends a regular message to the next process in the list
        Next_Pid = lists:nth(I+1,Pids),
        Next_Pid ! {Parent,{I,M,Pids}};
        %if there is only one process it behaves differently based on the amount of laps
        true ->
          M2 = M-1,
          if
            M2 ==0 ->
              X = I*M,
              Parent ! {X,Pids};
            true ->
              Next_Pid = lists:nth(I,Pids),
              Next_Pid ! {Parent,{I,M2,Pids}}
          end
      end,
      c_loop();

    %general case message
    {Parent,{I, M, Pids}} ->
      Self = self(),
      Last = lists:last(Pids),

      %checks if the process receiving the message is the last process in the list
      if
        Self == Last  ->

        %decrements M as one lap is complete
        M2 = M-1,
          if
            %if M is now 0 the laps are complete and the final message including the N*M result is sent off to the parent
            M2 ==0 ->
            X = I+1*M,
            Parent ! {X,Pids};
            true ->
             %if M =!= 0 more laps are needed and a message is sent to the first process in the list to start the new lap
             First = lists:nth(1,Pids),
             First ! {Parent,{I+1,M2,Pids}},
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
              Next_Pid ! {Parent,{I2,M,Pids}},
              c_loop();
              true ->
              Next_Pid = lists:nth(I2+1,Pids),
              Next_Pid ! {Parent,{I2,M,Pids}},
              c_loop()
          end

      end
  end.