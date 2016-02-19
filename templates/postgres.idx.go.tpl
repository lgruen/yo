{{ if .IsUnique }}
// {{ .Type }}By{{ if gt (len .Fields) 1 }}{{ .Name }}{{ else }}{{ range .Fields }}{{ .Field }}{{ end }}{{ end }} retrieves a row from {{ schema .TableSchema .TableName }} as a {{ .Type }}.
//
// Looks up using index {{ .IndexName }}.
func {{ .Type }}By{{ if gt (len .Fields) 1 }}{{ .Name }}{{ else }}{{ range .Fields }}{{ .Field }}{{ end }}{{ end }}(db XODB{{ goparamlist .Fields true }}) (*{{ .Type }}, error) {
	var err error

	// sql query
	const sqlstr = `SELECT ` +
		`{{ colnames .Table.Fields }} ` +
		`FROM {{ schema .TableSchema .TableName }} ` +
		`WHERE {{ colnamesquery .Fields " AND " }}`

	{{ shortname .Type }} := {{ .Type }}{
	{{- if .Table.PrimaryKeyField }}
		_exists: true,
	{{ end -}}
	}

	// run query
	XOLog(sqlstr{{ goparamlist .Fields false }})
	err = db.QueryRow(sqlstr{{ goparamlist .Fields false }}).Scan({{ fieldnames .Table.Fields (print "&" (shortname .Type)) }})
	if err != nil {
		return nil, err
	}

	return &{{ shortname .Type }}, nil
}
{{ else }}
// {{ .Plural }}By{{ .Name }} retrieves rows from {{ schema .TableSchema .TableName }}, each as a {{ .Type }}.
//
// Looks up using index {{ .IndexName }}.
func {{ .Plural }}By{{ .Name }}(db XODB{{ goparamlist .Fields true }}) ([]*{{ .Type }}, error) {
	var err error

	// sql query
	const sqlstr = `SELECT ` +
		`{{ colnames .Table.Fields }} ` +
		`FROM {{ schema .TableSchema .TableName }} ` +
		`WHERE {{ colnamesquery .Fields " AND " }}`

	// run query
	XOLog(sqlstr{{ goparamlist .Fields false }})
	q, err := db.Query(sqlstr{{ goparamlist .Fields false }})
	if err != nil {
		return nil, err
	}
	defer q.Close()

	// load results
	res := []*{{ .Type }}{}
	for q.Next() {
		{{ shortname .Type }} := {{ .Type }}{
		{{- if .Table.PrimaryKeyField }}
			_exists: true,
		{{ end -}}
		}

		// scan
		err = q.Scan({{ fieldnames .Table.Fields (print "&" (shortname .Type)) }})
		if err != nil {
			return nil, err
		}

		res = append(res, &{{ shortname .Type }})
	}

	return res, nil
}
{{ end }}

