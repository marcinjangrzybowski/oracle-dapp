(namespace 'free)

;; Define a keyset for the oracle provider
(define-keyset "free.oracle-provider-keyset" (read-keyset 'oracle-provider-keyset))

;; Define 'oracle' module
(module oracle "free.oracle-provider-keyset"
  "Oracle contract module"

  ;; Define data publishing capability
  (defcap PUBLISHING ()
    "Module publishing capability ensuring only oracle provider can feed data"
    ;; Ensure provider is authorised
    (enforce-keyset "free.oracle-provider-keyset"))

  ;; Define the `oracle-data-schema` schema for oracle data table
  (defschema oracle-data-schema
    "Schema for Oracle Data"
    key: string
    value: decimal
    timestamp: time)

  ;; Define the `oracle-data` table that uses the 'oracle-data-schema'
  (deftable oracle-data:{oracle-data-schema})

  ;; Define function for adding oracle data
  (defun insert-data (k:string v:decimal)
    "Insert new oracle data keyed by 'k' with value 'v', can only be called by oracle provider"
    (with-capability (PUBLISHING)
      (let ((t (at "block-time" (chain-data))))
        (write oracle-data k { "key": k, "value": v, "timestamp": t }))))

  ;; Define function for retrieving oracle data
  (defun get-data:decimal (k:string)
    "Get oracle data for a given key 'k'"
    (at "value" (read oracle-data k ["value"])))
)

;; Initialize oracle-data if necessary.
(if (not (read-msg 'upgrade))
  (create-table oracle-data)
  "Upgrade complete"
)
