// Abfrage: Events_erstellt
// Synthetisches Start-Event "Erstellt" je Fall (Zeitstempel = Ticketeingang, Priorität 1, ein Event pro Case-ID).
// Quelle "Tabelle92" = zusammengeführte API-Rohdaten im Excel-Workbook.

Events_erstellt = let
    Quelle = Excel.CurrentWorkbook(){[Name="Tabelle92"]}[Content],
    #"Umbenannte Spalten" = Table.RenameColumns(Quelle,{{"requested_datetime", "Ticket eingegangen"}, {"updated_datetime", "letztes Ticketupdate"}}),
    #"Umbenannte Spalten1" = Table.RenameColumns(#"Umbenannte Spalten",{{"status_notes", "Aktivität Text Mitarbeiter"}, {"datetime", "Zeitstempel"}}),
    #"Hinzugefügte benutzerdefinierte Spalte" = Table.AddColumn(#"Umbenannte Spalten1", "Aktivität", each
        /* Aktivitäts-Mapping: siehe 01_aktivitaets_mapping.m */ ...),
    #"Neu angeordnete Spalten" = Table.ReorderColumns(#"Hinzugefügte benutzerdefinierte Spalte",{"service_request_id", "Ticket eingegangen", "service_name", "zipcode", "lat", "long", "title", "Zeitstempel", "Aktivität Text Mitarbeiter", "Aktivität"}),
    #"Entfernte Spalten3" = Table.RemoveColumns(#"Neu angeordnete Spalten",{"Zeitstempel"}),
    #"Umbenannte Spalten2" = Table.RenameColumns(#"Entfernte Spalten3",{{"service_request_id", "Case_ID"}, {"Ticket eingegangen", "Zeitstempel"}}),
    #"Entfernte Spalten4" = Table.RemoveColumns(#"Umbenannte Spalten2",{"Aktivität"}),
    #"Hinzugefügte benutzerdefinierte Spalte1" = Table.AddColumn(#"Entfernte Spalten4", "Aktivität", each "Erstellt"),
    #"Hinzugefügte benutzerdefinierte Spalte2" = Table.AddColumn(#"Hinzugefügte benutzerdefinierte Spalte1", "Synthetisch Erstellt", each 1),
    #"Hinzugefügte benutzerdefinierte Spalte3" = Table.AddColumn(#"Hinzugefügte benutzerdefinierte Spalte2", "AktivitätenPriorität", each 1),
    #"Entfernte Duplikate" = Table.Distinct(#"Hinzugefügte benutzerdefinierte Spalte3", {"Case_ID"}),
    #"Umbenannte Spalten3" = Table.RenameColumns(#"Entfernte Duplikate",{{"Synthetisch Erstellt", "Synthetisch erstellt"}}),
    #"Geänderter Typ" = Table.TransformColumnTypes(#"Umbenannte Spalten3",{{"Zeitstempel", type datetimezone}}),
    #"Entfernte Spalten" = Table.RemoveColumns(#"Geänderter Typ",{"description", "letztes Ticketupdate", "address", "status_name", "Aktivität Text Mitarbeiter"}),
    #"Entfernte Duplikate1" = Table.Distinct(#"Entfernte Spalten", {"Case_ID"})
in
    #"Entfernte Duplikate1"
