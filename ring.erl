-module(ring).
-compile(export_all).


start(N,M)->
  Parent = spawn(fun()-> p_loop() end),
  Pids = create_ps(N,[]),
  io:format("Pids: ~p~n",[Pids]),
  Child = lists:nth(1,Pids),
  Child ! {self(),{Parent,{0,M,Pids}}},
  p_loop().

 create_ps(0,Pids) ->
   lists:reverse(Pids);
 create_ps(N, Pids)->
  Pid =spawn(fun() -> c_loop() end),
    create_ps(N-1,[Pid|Pids]).



p_loop()->
  receive
    {From, {X, Pids}}->
      %io:format("in Parent loop: ~p~n",[X]),
      lists:foreach(fun(Y) -> exit(Y,kill) end, Pids),

      io:format("~p~n",[X])

  end.

c_loop()->
  receive
    {From,{Parent,{I, 0, Pids}}} ->
      io:format("No messages sent"),
      c_loop();
    {From, {Parent,{0, M, Pids}}} ->
      Self = self(),
      io:format("First pid = ~p~n",[Self]),
      I = 1,
      Next_Pid = lists:nth(I+1,Pids),
      Next_Pid ! {self(),{Parent,{I,M,Pids}}},
      c_loop();
    {From, {Parent,{I, M, Pids}}} ->
      Self = self(),
      io:format("In Pid ~p~n",[Self]),
      Last = lists:last(Pids),

      if
        Self == Last  ->
        % io:format("In Pid ~p~n",[Self]),
        M2 = M-1,
          if
            M2 ==0 ->
            X = I+1*M,
            Parent ! {Self,{X,Pids}};
            true ->
             First = lists:nth(1,Pids),
             First ! {self(),{Parent,{I+1,M2,Pids}}},
             c_loop()
          end;
        true ->
          I2 = I+1,
          if
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
          %c_loop(Parent,{I2,M,Pids})
      end
  end.