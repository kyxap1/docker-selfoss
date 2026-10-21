<?php
// Deletes the newest 3 items of sources 18 and 43 so an update must re-deliver them.
$db = new PDO('sqlite:/selfoss/data/sqlite/selfoss.db');
foreach ([18, 43] as $id) {
    $n = $db->exec("DELETE FROM items WHERE id IN (SELECT id FROM items WHERE source = $id ORDER BY datetime DESC LIMIT 3)");
    echo "source $id: deleted $n items\n";
}
