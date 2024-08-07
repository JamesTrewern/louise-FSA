:-module(generator_configuration, [action_representation/1
                                  ,maze_file/1
                                  ,primitives_file/2
                                  ,test_primitives_file/2
                                  ,theme/1
                                  ]).

/** <module> Configuration options for move_generator and map_display.
*/

%!      action_representation(?Representation) is semidet.
%
%       Whether the state vector will have an action-stack or not.
%
%       Currently known representations:
%       * stack_based: the state vector has an action stack where action
%       tokens are pushed to each time an action is taken.
%       * memoryless: the state vector has no action stack.
%
%action_representation(stack_based).
action_representation(memoryless).


%!      maze_file(?Path) is semidet.
%
%       Path loading generated maze maps.
%
%       Path should be the path to a Prolog file with load directives
%       for the mazes generated by James' map generator (or any other
%       generator we end up using).
%
%       That file is loaded to import the generated mazes into the
%       move_generator module, from where they are combined with
%       primitive moves and written to a new file, defined in
%       primitives_file/1.
%
maze_file(data(mazes_new/my_mazes/'zero.pl')).
maze_file(data(mazes_new/my_mazes/'four_mazes.pl')).


%!      primitives_file(?Path,?Module) is semidet.
%
%       Path to the Prolog Module holding primitive moves and maze maps.
%
primitives_file(data(mazes_new/'primitives_stack_based.pl'),primitives).


%!      test_primitives_file(?Path,?Module) is semidet.
%
%       Path and Module name for a file with primitives for testing.
%
test_primitives_file(data(mazes_new/'test_primitives.pl'),primitives).


%!      theme(?Theme) is semidet.
%
%       Theme for map and path printing.
%
%       Known themes:
%
%       * text: prints map in coloured text characters.
%       * boxes: prints map in coloured box drawings.
%
%       Example of 'text' theme (without the colours):
%       ==
%       ?- map_display:theme(T).
%       T = text.
%
%       ?- trace_path(0).
%       ˅ w f f f f f
%       ˅ w w w f w w
%       ˃ ˃ ˅ w f f f
%       w w ˅ w w w f
%       f w ˃ ˃ ˃ ˃ ˅
%       f w w w w w ˅
%       f f f f f f e
%       true.
%       ==
%
%       % Example of 'boxes' theme (without the colours):
%       ==
%       ?- map_display:theme(T).
%       T = boxes.
%
%       ?- trace_path(0).
%       ▼ ■ □ □ □ □ □
%       ▼ ■ ■ ■ □ ■ ■
%       ► ► ▼ ■ □ □ □
%       ■ ■ ▼ ■ ■ ■ □
%       □ ■ ► ► ► ► ▼
%       □ ■ ■ ■ ■ ■ ▼
%       □ □ □ □ □ □ █
%       true.
%       ==
%
%theme(text).
theme(boxes).
