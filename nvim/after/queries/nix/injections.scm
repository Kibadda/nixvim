; extends

(binding
  (attrpath
    (string_expression (string_fragment) @injection.filename)
    (identifier) @_text
  )
  (indented_string_expression
    (string_fragment) @injection.content
    (#set! injection.combined)
  )

  (#eq? @_text "text")
)

(binding
  (attrpath
    (string_expression (string_fragment) @injection.filename)
  )
  (attrset_expression
    (binding_set
      (binding
        (attrpath
          (identifier) @_text
        )
        (indented_string_expression
          (string_fragment) @injection.content
          (#set! injection.combined)
        )
      )
    )
  )

  (#eq? @_text "text")
)
