let
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7HDge3CZEgNK6j3mGeMeJDWCcEUmScNnIzNb+CXns2";
in
{
  "pass.age".publicKeys = [ local ];
}
