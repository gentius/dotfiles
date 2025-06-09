;;;###autoload
(defun sql-duckdb (&optional buffer)
  "Run duckdb as an inferior process.

Taken from: https://github.com/duckdb/duckdb/discussions/8099

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-duckdb-program'.  Login uses
the variables `sql-user', `sql-password', `sql-database', and
`sql-server' as defaults, if set.  Additional command line parameters
can be stored in the list `sql-duckdb-options'.

The buffer is put in SQL interactive mode, giving commands for sending
input.  See `sql-interactive-mode'.

To set the buffer name directly, use \\[universal-argument]
before \\[sql-duckdb].  Once session has started,
\\[sql-rename-buffer] can be called separately to rename the
buffer.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-duckdb].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive "P")
  (sql-product-interactive 'duckdb buffer))
(defun sql-duckdb-completion-object (sqlbuf _schema)
  (sql-redirect-value sqlbuf "show tables" "^\\(\\sw\\(?:\\sw\\|\\s_\\)*\\)," 1))

(defcustom sql-duckdb-program (or (executable-find "duckdb")
                                  "duckdb")
  "Command to start duckdub.

Starts `sql-interactive-mode' after doing some setup."
  :type 'file
  :group 'SQL)

(defcustom sql-duckdb-options nil
  "List of additional options for `sql-duckdb-program'."
  :type '(repeat string)
  :version "20.8" ;; FIXME: What is this?
  :group 'SQL)

(defcustom sql-duckdb-login-params '((database :file nil
                                               :must-match confirm))
  "List of login parameters needed to connect to duckdb."
  :type 'sql-login-params
  :version "26.1"
  :group 'SQL)

(add-to-list 'sql-product-alist
             '(duckdb
               :name "duckdb"
               :free-software nil
               :font-lock sql-mode-sqlite-font-lock-keywords  ;; Use sqlite for now
               :sqli-program sql-duckdb-program
               :sqli-options sql-duckdb-options
               :sqli-login sql-duckdb-login-params
               :sqli-comint-func sql-comint-sqlite
               :list-all "show tables"
               :list-table "describe %s"
               :completion-object sql-duckdb-completion-object
               :prompt-regexp "^D "
               :prompt-length 2
               :prompt-cont-regexp "^> "))

(provide 'sql-duckdb)
