-module(double1).
-compile(export_all).

start()->
  Pid = spawn(fun() -> loop() end ),
  register(double1,Pid),
  Pid.


loop()->
  receive

     X ->
        Y =2*X,
        io:format("Doubled ~p~n",[Y]),
        loop()
  end.


