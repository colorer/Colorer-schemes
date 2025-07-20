% Комментарий

-module(test_colorer).
-author('email@ex.com').

-export([start/2, 'test fun 2'/1]).

-include("test_colorer.hrl").

-define(PI, 3.14159265358).
-define(div2(P), P/2).

-record(my_rec, {param1, param2, param3}).

start({}, P2) when is_integer(P2), P2>1 andalso P2<5 ->
    case P2 of
	{tuple, 2, [list, atom1, 'atom2', "string"]} ->
	    ?div2(0);
	<<1, "string", 5/signed-integer>> ->
	    hello_world;
	_ ->
	    receive
		{message, "Hello"} ->
		    List = [ fact(El) || El <- lists:seq(1, 5) ],
		    Bin = << <<El:16/integer >> || El <- lists:seq(1, 5) >>,
		    Bin2 = <<0, 1, 0, 2, 0, 3, 0, 4, 0, 5>>,
		    <<_:32, 0, 3, Rest/bitstring>> = Bin2,
		    if
			Bin == Bin2 ->
			    fun(N) -> fact(N) end;
			true -> 
			    fun fact/1
		    end;
		{day, {Y, M, D}}->
		    fun_rec(),
		    ?PI
	    after
		5000 ->
		    timeout
	    end
    end;
start(P1, P2) ->
    P1 + P2.

fact(N) when N>0 -> % Ещё комментарий
    N * fact(N-1);
fact(0) ->
    1.

fun_rec() ->
    R = #my_rec{param1=5, param3=hello},
    R2 = R#my_rec{param3=world},
    P = R2#my_rec.param1,
    case ets:match(my_cool_hash_table, #my_rec{param2=P, param1='_'}) of
	[] ->
	    not_found;
	Data ->
	    Data
    end.

'test fun 2'(Param) ->
    Num1 = 123,
    Num2 = 2#101,
    Num3 = 16#1f,
    Num4 = 1.5,
    Num5 = $5,
    Num6 = 3.1e-0,
    Num7 = $', 
    %Num7 = $",  
    %Num7 = $\",
    Num7 = $\',
    Num8 = $@,
    Num9 = $$,
    Param+Num1+Num2+Num3+Num4+Num5+Num6+Num7+Num8+Num9. % == Param+355.6
