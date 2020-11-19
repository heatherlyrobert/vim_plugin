#!/bin/awk -f

BEGIN {
   # FS = "( )*[|]( )*";
   FS = "( )*[:]( )*";
   g_num_lines    = 0;
   g_num_entries  = 0;
   g_num_errors   = 0;
   g_num_warnings = 0;
   g_num_messages = 0;
   g_nothing      = "-";
   ##---(error tags)----------------------------##
   g_major        = 1;
   g_minor        = 0;
}

function tag_next () {
   ##---(normal incrementing)-------------------##
   ++g_minor;
   ##---(test minor range)----------------------##
   if (g_minor > 26) {
      ++g_hmajor;
      g_hminor = 1;
   }
   ##---(test major range)----------------------##
   if (g_hmajor > 12) {
      g_hmajor = 45 - 64;
      g_hminor = 45 - 64;
   }
   ##---(complete)------------------------------##
   return sprintf("%c%c", g_major + 64, g_minor + 64);
}

function print_header () {
   return;
}


function print_type (a_type) {
   #---(list the lines)--------------------------#
   for (x = 1; x <= g_num_lines; x++) {
      if (g_type[x] != a_type)  continue;
      short = "E";
      if (a_type != "error") short = "-";
      #---(print a well formatted line)----------#
      # these column separators make later regex mapping unambiguous
      printf("%s  %1d %-18.18s [--] %20.20s : %4d : %-100.100s  #1#  %s  #2#  %s  #3#  %d  #4#  %s  #5#  %s  #6#  %s  #7#  %s\n",
             tag_next(), 0, g_base[x], " ", g_line[x], g_desc[x],
             g_full[x], g_file[x], g_line[x], g_desc[x], g_obje[x], g_text[x],
             short);
   }
   #---(add a separator)-------------------------#
   return;
}

{  ++g_num_lines; }

$0 ~ /: error: / {
   ##---(prepare)-------------------------------##
   ++g_num_entries;
   ##---(full text)-----------------------------##
   g_text[g_num_entries]     = $0;
   ##---(file info)-----------------------------##
   g_full[g_num_entries]     = $1;
   match($1, "[A-Za-z0-9_.-]+$");
   g_base[g_num_entries]     = substr($1, RSTART, RLENGTH);
   g_line[g_num_entries]     = $2;
   ##---(error)---------------------------------##
   if ($3 == "error") {
      g_type[g_num_entries]     = $3;
      g_desc[g_num_entries]     = $4;
      if ($6 !~ /^$/) g_desc[g_num_entries] = $4 "::" $6;
   }
   else
   {
      g_type[g_num_entries]     = $4;
      g_desc[g_num_entries]     = $5;
      if ($7 !~ /^$/) g_desc[g_num_entries] = $5 "::" $7;
   }
   ##---(object)--------------------------------##
   temp = g_desc[g_num_entries];
   match(temp, "'[A-Za-z0-9_.: -]+'");
   if (RSTART > 0)
      g_obje[g_num_entries]   = substr(temp, RSTART+1, RLENGTH-2);
   else
      g_obje[g_num_entries]   = "";
   ##---(update stats)--------------------------##
   ++g_num_entries;
   ++g_num_errors;
   ##---(done)----------------------------------##
}

$0 ~ /: undefined reference to `/ {
   ##---(prepare)-------------------------------##
   ++g_num_entries;
   ##---(full text)-----------------------------##
   g_text [g_num_entries]     = $0;
   ##---(file info)-----------------------------##
   g_full [g_num_entries]     = $1;
   match ($1, "/[A-Za-z0-9_.-]+$");
   g_base [g_num_entries]     = substr ($1, RSTART + 1, RLENGTH - 1);
   g_line [g_num_entries]     = $2;
   ##---(error)---------------------------------##
   g_type [g_num_entries]     = "error";
   g_desc [g_num_entries]     = $3;
   ##---(object)--------------------------------##
   temp = g_desc [g_num_entries];
   match(temp, "`[A-Za-z0-9_.: -]+'");
   if (RSTART > 0)
      g_obje[g_num_entries]   = substr (temp, RSTART + 1, RLENGTH - 2);
   else
      g_obje[g_num_entries]   = "";
   ##---(update stats)--------------------------##
   ++g_num_entries;
   ++g_num_errors;
   ##---(done)----------------------------------##
}

$0 ~ /: warning: / {
   ++g_num_warnings;
}

$0 ~ /Nothing to be done for '/ {
   g_nothing  = "y"
}

END {
   if (g_num_errors > 0)
      printf("compiler (FAIL)");
   # else if (g_num_warnings > 0)
   #    printf("compiler (warn)");
   # else if (g_num_messages > 0)
   #    printf("compiler (warn)");
   else
      printf("compiler (pass)");

   if (g_nothing == "y") printf(" compile already up do date (nothing to do)                                                    \n");
   else
   {
      printf(" errs=%03d, warn=%03d, msgs=%03d, line=%03d                                                       \n", g_num_errors, g_num_warnings, g_num_messages, g_num_lines);
      for (x = 1; x <= g_num_messages; x++)
         printf("   *  %s\n", g_messages[x]);
      print_type("error");
      # print_type("warning");
      if (g_num_errors > 0)  printf("end of compiler feedback                                                                                    \n");
      exit -1;
   }
}

