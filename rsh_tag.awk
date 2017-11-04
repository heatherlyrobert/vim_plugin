#!/bin/awk -f

BEGIN {
   FS  = "( )**";
   g_num_lines     = 0;
   g_file_save     = "";
   g_file_count    = 0;
}


function list_type(a_file, a_type, a_tagged) {
   #---(start by getting a count)----------------#
   g_num_print = 0;
   for (x = 1; x <= g_num_lines; x++) {
      if (g_file[x] != a_file || g_type[x] != a_type)  continue;
      ++g_num_print;
   }
   if (g_num_print == 0) return;
   #---(print the header)------------------------#
   printf("%s (%d)\n", a_type, g_num_print);
   #---(list the lines)--------------------------#
   for (x = 1; x <= g_num_lines; x++) {
      if (g_file[x] != a_file || g_type[x] != a_type)  continue;
      g_1st = "-";
      g_2nd = "-";
      if (a_tagged == "y") {
         #---(increment the hints)------------------#
         if (g_hint_major > 0 && g_hint_major < 26) {
            ++g_hint_minor;
            if (g_hint_minor > 26) {
               ++g_hint_major;
               g_hint_minor = 1;
            }
         }
         if (g_hint_major >= 26) {
            g_hint_major = 45 - 96;
            g_hint_minor = 45 - 96;
         }
         g_1st = g_hint_major + 96;
         g_2nd = g_hint_minor + 96;
      }
      #---(print a well formatted line)----------#
      # these column separators make later regex matting unambiguous
      printf("%c%c  %-40.40s  #1#  %-5d  #2#  %s  #3#  %s  #4#  %s  #5#  \n",
             g_1st, g_2nd, g_name[x],
             g_line[x], g_file[x], g_type[x], g_name[x]);
   }
   #---(add a separator)-------------------------#
   printf("\n");
}


$1 ~ /^[A-Za-z]/ {
   #---(parse the data and store)----------------#
   ++g_num_lines;
   g_name[g_num_lines] = $1;
   g_type[g_num_lines] = $2;
   g_line[g_num_lines] = $3;
   g_file[g_num_lines] = $4;
   #---(check on file change)--------------------#
   if (g_file_save != $4) {
      ++g_file_count;
      g_inventory[g_file_count] = $4;
      g_file_save = $4;
   }
   #---(complete)--------------------------------#
}


END {
   #---(run through the files)-------------------#
   for (i = 1; i <= g_file_count; i++) {
      printf("%-40.40s    FILE\n\n", g_inventory[i]);
      list_type(g_inventory[i], "function",     "y")
      list_type(g_inventory[i], "method",       "y")

      list_type(g_inventory[i], "externvar",    "-")
      list_type(g_inventory[i], "variable",     "y")
      list_type(g_inventory[i], "constant",     "y")
      list_type(g_inventory[i], "macro",        "y")
      list_type(g_inventory[i], "enum",         "y")
      list_type(g_inventory[i], "struct",       "y")
      list_type(g_inventory[i], "union",        "y")

      list_type(g_inventory[i], "label",        "-")
      list_type(g_inventory[i], "augroup",      "-")
      list_type(g_inventory[i], "exception",    "-")

      list_type(g_inventory[i], "class",        "-")
      list_type(g_inventory[i], "member",       "-")
      list_type(g_inventory[i], "typedef",      "y")

      list_type(g_inventory[i], "prototype",    "y")

      list_type(g_inventory[i], "namespace",    "-")
      for (j = 1; j < 100; ++j) printf("\n");
   }
   printf("%d\n%d\n", g_hint_major, g_hint_minor);
   exit 0;
}
