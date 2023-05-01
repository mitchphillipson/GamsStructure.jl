# GamsStructure.jl
 
Current Issues:

1. ~~Getting indices in parameters is very slow, like 10X slower than a regular array. I think the issue
is needing to allow set elements to have a boolean on/off. Whenever you ~~ Fixed


Ideas for future addition:

1. Dataframe to parameter. 
    1. Something where it will make the set at the same time
2. ~Have parameter have an optional columns argument so you can specify columns~
3. ~Zero dimensional parameters (or constants)~ Implemented as GamsScalars
4. Make parameters print better.
5. Search over descriptions
6. Load/Save a GamsUniverse in a meaningful way. Load/Save formats
    1. CSV -> Loading implemented
    2. CSV -> Unloading implemented
    2. ZIP -> Perhaps a nice way to save a bunch of data at once.
7. Write unit tests
8. 
