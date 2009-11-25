#!/bin/awk -f

BEGIN {
   FS  = "( )**";
   g_num_lines     = 0;
}


function list_type(a_type) {
   g_num_print = 0;
   for (x = 1; x <= g_num_lines; x++)
      if (g_type[x] == a_type) ++g_num_print;
   if (g_num_print == 0) return;
   printf("%s (%d)\n", a_type, g_num_print);
   for (x = 1; x <= g_num_lines; x++) {
      if (g_type[x] == a_type) {
         if (g_hint_major > 0 && g_hint_major < 13) {
            ++g_hint_minor;
            if (g_hint_minor > 26) {
               ++g_hint_major;
               g_hint_minor = 1;
            }
         }  # HCSC.vim uses m-n
         if (g_hint_major >= 13) {
            g_hint_major = 45 - 96;
            g_hint_minor = 45 - 96;
         }
         # these column separators make later regex matting unambiguous
         printf("%c%c  %-40.40s  #1#  %-5d  #2#  %s  #3#  %s  #4#  %s  #5#  \n",
                g_hint_major + 96, g_hint_minor + 96, g_name[x],
                g_line[x], g_file_name, g_type[x], g_name[x]);
      }
   }
   printf("\n");
}


$1 ~ /^[A-Za-z]/ {
   # store the tag-type
   ++g_num_lines;
   g_name[g_num_lines] = $1;
   g_type[g_num_lines] = $2;
   g_line[g_num_lines] = $3;
}


END {
   printf("%-40.40s    FILE\n\n", g_file_name);

   list_type("function")
   list_type("method")

   list_type("externvar")
   list_type("variable")
   list_type("constant")
   list_type("macro")
   list_type("enum")
   list_type("struct")
   list_type("union")

   list_type("label")
   list_type("augroup")
   list_type("exception")

   list_type("class")
   list_type("member")
   list_type("typedef")

   list_type("prototype")

   list_type("namespace")


   printf("%d\n%d\n", g_hint_major, g_hint_minor);
   exit 0;
}
