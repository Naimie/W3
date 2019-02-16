-module(double).
-compile(export_all).

test()->
  %To test 3.1
  %In the console write:
  % c(double).
  % double:start().
  % whereis(double) ! 3.  = Input times 2 = 6
  % whereis(double) ! y.  = Error message as process crashes
  % whereis(double) ! 3.  = Exception error as process has died.
  hooray.


start()->
  Pid = spawn(fun() -> loop() end ),
  register(double,Pid),
  Pid.

%sleep(T)->
%  %sleep for T milliseconds

loop()->
  receive
     X ->
        Y =2*X,
        io:format("Input times 2 = ~p~n",[Y]),
        loop()

%  after T ->
%    true
  end.


