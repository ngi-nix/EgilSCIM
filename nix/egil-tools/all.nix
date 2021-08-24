{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, egilToolPackageNames
}:
{ lib
, symlinkJoin
, ...
}@pkgs:

let
  inherit (builtins) filter attrValues;
  inherit (lib) hasPrefix getAttrs unique;

  pname = "egil-tools";
  egilToolPackages = attrValues (getAttrs egilToolPackageNames pkgs);
  license = unique (map (drv: drv.meta.license) egilToolPackages);
in
symlinkJoin {
  inherit pname version;
  name = "${pname}-${version}";

  paths = egilToolPackages;

  meta = {
    description = "Tools associated with the EGIL client";
    longDescription =
      "Tools that may simplify usage of the EGIL client. All tools can be " +
      "run with the -h flag to show a brief description of how to run the " +
      "tool.";

    inherit homepage downloadPage changelog;

    inherit license maintainers platforms;
  };
}
