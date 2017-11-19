#!/bin/awk -f

#
# CLI args...
#   1) g_func     = unique function name

BEGIN {
   FS              = "( )**";
   x_found         = "-";
   x_target        = (g_func "()");
   x_count         = 0;
}

##---(find our function)-----------------##
$0 ~ /^[a-zA-Z]/ {
   if (x_target == $1) {
      x_found = "y";
   }
   else {
      x_found = "-";
   }
}

$0 ~ /^   / {
   if (x_found == "y") {
      ++x_count;
   }
}

END {
   printf ("%d\n", x_count);
   exit x_count;
}
