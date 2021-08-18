{ version
, homepage
, maintainers
, platforms
, egilToolPackageNames
}:
pkgs:

let
  inherit (builtins) filter attrValues;
  inherit (pkgs.lib) hasPrefix getAttrs unique;

  pname = "egil-tools";
  egilToolPackages = attrValues (getAttrs egilToolPackageNames pkgs);
  license = unique (map (drv: drv.meta.license) egilToolPackages);
in
pkgs.symlinkJoin {
  inherit pname version;
  name = "${pname}-${version}";

  paths = egilToolPackages;

  meta = {
    inherit homepage maintainers platforms license;

    description = "Tools associated with the EGIL client";
    longDescription =
      "Tools that may simplify usage of the EGIL client. All tools can be " +
      "run with the -h flag to show a brief description of how to run the " +
      "tool.";
  };
}
