#!/bin/awk -f

BEGIN {
   # FS = "( )*[|]( )*";
   FS = "( )*[:]( )*";
   g_num_lines    = 0;
   g_num_entries  = 0;
   g_num_errors   = 0;
   g_num_warnings = 0;
   g_num_messages = 0;
}


{  ++g_num_lines; }


$2 ~ /Nothing to be done/ || $2 ~ /no makefile found/ {
   ++g_num_messages;
   g_messages[g_num_messages]    = $2;
}


$3 ~ /^error$/ || $3 ~ /^warning$/ {
   ++g_num_entries;
   # parse the fields -----------------------------------------------#
   g_filefull = $1;
   match(g_filefull, "[A-Za-z0-9_.-]+$");
   g_filebase = substr($1, RSTART, RLENGTH);
   g_line     = $2;
   g_type     = $3;
   g_message  = $4;
   ## tie the entire message together if it hits an class name ------#
   if ($6 !~ /^$/) g_message = $4 "::" $6;
   match(g_message, "'[A-Za-z0-9_.: -]+'");
   if (RSTART > 0)
      g_object   = substr(g_message, RSTART+1, RLENGTH-2);
   else
      g_object   = "";
   if (g_type == "error") ++g_num_errors;
   else                   ++g_num_warnings;
   # save in an array -----------------------------------------------#
   g_entry[g_num_entries, 1] = g_filefull;
   g_entry[g_num_entries, 2] = g_filebase;
   g_entry[g_num_entries, 3] = g_type;
   g_entry[g_num_entries, 4] = g_line;
   g_entry[g_num_entries, 5] = g_message;
   g_entry[g_num_entries, 6] = g_object;
   g_entry[g_num_entries, 7] = $0;
}


END {
   if (g_num_errors > 0)
      printf("gcc/make (FAIL) ");
   else if (g_num_warnings > 0)
     printf("gcc/make (warn) ");
   else if (g_num_messages > 0)
     printf("gcc/make (warn) ");
   else
     printf("gcc/make (pass) ");

   printf("errors = %02d, warnings %02d, messages %02d, lines %03d                      \n",
      g_num_errors, g_num_warnings, g_num_messages, g_num_lines);

   for (x = 1; x <= g_num_messages; x++)
      printf("   *  %s\n",
         g_messages[x]);
   for (x = 1; x <= g_num_entries; x++) {
      if (g_entry[x,3] == "error")
         printf("  E  %-18.18s : %4d : %-100.100s  #1#  %s  #2#  %s  #3#  %d  #4#  %s  #5#  %s  #6#  %s  #7#  \n",
            g_entry[x,2], g_entry[x,4], g_entry[x,5],
            g_entry[x,1], g_entry[x,2], g_entry[x,4],
            g_entry[x,5], g_entry[x,6], g_entry[x,7]);
   }
   for (x = 1; x <= g_num_entries; x++) {
      if (g_entry[x,3] == "warning")
         printf("  -  %-18.18s : %4d : %-100.100s  #1#  %s  #2#  %s  #3#  %d  #4#  %s  #5#  %s  #6#  %s  #7#  \n",
            g_entry[x,2], g_entry[x,4], g_entry[x,5],
            g_entry[x,1], g_entry[x,2], g_entry[x,4],
            g_entry[x,5], g_entry[x,6], g_entry[x,7]);
   }
}

