<?php
// Same bootstrap as cliupdate.php, but for one source.
chdir("/selfoss");
require "/selfoss/src/common.php";
$loader = $dice->create(helpers\ContentLoader::class);
$loader->updateSingle((int) $argv[1]);
echo "cli update of source $argv[1] done\n";
