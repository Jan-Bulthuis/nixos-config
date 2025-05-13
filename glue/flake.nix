{
  description = "Some glue";

  inputs = { };

  outputs =
    inputs:
    let
      glue = import ./lib { inherit inputs; };
    in
    {
      __functor = _: glue;
    };
}
