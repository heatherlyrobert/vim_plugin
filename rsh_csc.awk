#!/bin/awk -f

# parameters
#  g_hmajor
#  g_hminor
#  g_symbol

BEGIN {
   FS       = ":( )*";
   g_count  = 0;
}



{
   ++g_count;
   ##---(parse fields)---------------------------#
   g_file = $1;
   g_line = $2;
   g_text = substr($0, length(g_file) + length(g_line) + 3, 10000);
   ##---(cut leading spaces)---------------------#
   g_disp = g_text;
   match(g_disp, "[ ]*");
   g_pref =  RLENGTH;
   if (g_pref > 0) {
      g_disp = substr(g_disp, g_pref + 1, 10000);
   }
   ##---(get extra spaces out)-------------------#
   gsub("[ ]+", " ", g_disp);
   ##---(save the result)------------------------#
   g_entry[g_count, 1] = g_file;
   g_entry[g_count, 2] = g_line;
   g_entry[g_count, 3] = g_disp;
   g_entry[g_count, 4] = g_text;
}


END {
   printf("grep/cscope (%s) found  %d  matches for \"%s\" %s %100.100s\n", g_option, g_count, g_symbol, g_scope, " ");
   for (x = 1; x <= g_count; x++) {
      if (g_hmajor > 0 && g_hmajor < 16) {
         ++g_hminor;
         if (g_hminor > 26) {
            ++g_hmajor;
            g_hminor = 1;
         }
      }
      if (g_hmajor >= 15) {
         g_hmajor = 45 - 96;
         g_hminor = 45 - 96;
      }
      printf("%c%c  %1d %-18.18s [--] %20.20s : %4d : %-100.100s ::: %s\n",
             g_hmajor + 96, g_hminor + 96, 0,
             g_entry[x, 1], " ", g_entry[x, 2], g_entry[x, 3], g_entry[x, 4]);
   }
   exit 0;
}
