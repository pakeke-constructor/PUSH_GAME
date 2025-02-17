

local default_T1 = {

    id = "default_T1",

    tries = 20, -- If a structure is generated > `tries` times and still does not
            -- fit, do not generate this structure.
            -- The lower this is, the faster worlds will be generated.

    min_structures = 30, -- number of structures will be within this range.
    max_structures = 40,
    -- Note that after the number of structures has been chosen,


    structures = {

    [  -- Small room structure with coin inside,
    --  guarded by 'e'.
        {
            {"?????",
            "?????",
            "?????",
            "?????",
            "?????"}
            ,
            {"?????",
            "?#e#?",
            "?#c#?",
            "?###?",
            "?????"}
        }
    ] = 0.03 -- weight of being chosen out of all structures
    ,
    [ -- Item box
        {
            {"?????",
            "?????",
            "?????",
            "?????",
            "?????"}
            ,
            {"?????",
            "?###?",
            "?#i#?",
            "?###?",
            "?????"}
        }
    ] = 0.05 -- weight of being chosen out of all structures
    ,
    [  -- Small room structure with coin inside,
    --  guarded by 'e'.
        {
            {"?????",
            "?????",
            "?????",
            "?????",
            "?????"}
            ,
            {"?????",
            "?###?",
            "?#^??",
            "?###?",
            "?????"}
        }
    ] = 0.03 -- weight of being chosen out of all structures
    ,
    [  -- Small room structure with coin inside,
    --  guarded by 'e'.
        {
            {"?????",
            "?????",
            "?????",
            "?????",
            "?????"}
            ,
            {"?????",
            "?###?",
            "??##?",
            "???#?",
            "?????"}
        }
    ] = 0.03 -- weight of being chosen out of all structures
    ,

    [
        {  -- Large object surrounded by small objects
            {"???",
            "???",
            "???"}
            ,
           {"^p^",
            "plp",
            "^p^"}
        }
    ] = 0.04
    ,


    [  -- Decoration field with physics objects in center
        {
            {"? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?",
            "? ? ? ? ? ? ?"}
            ,
            {"^ ^ ^ ^ ^ ^ ^",
            "^ l ^ ^ ^ l ^",
            "^ ^ ^ p ^ ^ ^",
            "^ ^ p p p ^ ^",
            "^ ^ ^ p ^ ^ ^",
            "^ l ^ ^ ^ l ^",
            "^ ^ ^ ^ ^ ^ ^"}
        }
    ] = 0.3
    ,


    [  -- Open room filled with unique enemies
        {
            {"???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????"}
            ,
            {"^^.^^.^",
            "^#####^",
            ".#^^.#^",
            "^^.i^^^",
            "^#^^^#^",
            "p#####.",
            "^p^..^p"}
        }
    ] = 0.1
    ,

    [  -- Closed room with random (non-walled) interior 1
        {
            {"???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????"}
            ,
            {"? ? ? ? ? ? ?",
            "? # # # # # ?",
            "? # . ? . # ?",
            "? . ? i ? # ?",
            "? # . ? . # ?",
            "? # # # # # ?",
            "? ? ? ? ? ? ?"}
        }
    ] = 0.1
    ,

    [--  Closed room with random (non-walled) interior 2
        {
            {"???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????"}
            ,
            {"? ? ? ? ? ? ?",
            "? # # # # # ?",
            "? # . ? . # ?",
            "? # ? i ? . ?",
            "? # . ? . # ?",
            "? # # # # # ?",
            "? ? ? ? ? ? ?"}
        }
    ] = 0.1
    ,

    [
        { --  Closed room with random (non-walled) interior 3
            {"???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????"}
            ,
            {"? ? ? ? ? ? ?",
            "? # # # # # ?",
            "? # . ? . # ?",
            "? # ? i ? # ?",
            "? # . ? . # ?",
            "? # # . # # ?",
            "? ? ? ? ? ? ?"}
        }
    ] = 0.1
    ,

    [
        { --  Closed room with random (non-walled) interior 4
            {"???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????",
            "???????"},

            {"? ? ? ? ? ? ?",
            "? # # . # # ?",
            "? # . ? . # ?",
            "? # ? ? ? # ?",
            "? # . ? . # ?",
            "? # # # # # ?",
            "? ? ? ? ? ? ?"}
        }
    ] = 0.1
    ,
    [
        {
            {"????",
             "????",
             "????",
             "????"},

             {"????",
              "??l?",
              "?l??",
              "????"}
        }
    ] = 0.1
}

}

-- Higher Tier worlds will have things like Bossfights, artefacts etc.

return default_T1