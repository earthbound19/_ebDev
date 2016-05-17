<?php
// header( "Location: http://earthbound.io/q/search.php?query=misatu_supakuru&search=1" );

header( "Location: http://earthbound.io/q/search.php?query=" . htmlspecialchars($_GET["query"]) . '&search=1'
?>