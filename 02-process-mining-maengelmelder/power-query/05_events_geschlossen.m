// Abfrage: Events_geschlossen
// Synthetisches End-Event "geschlossen" je Fall (Zeitstempel = letztes Ticketupdate, Priorität 99).
// Quelle "Tabelle92" = zusammengeführte API-Rohdaten im Excel-Workbook.

Events_geschlossen = let
    Quelle = Excel.CurrentWorkbook(){[Name="Tabelle92"]}[Content],
    #"Umbenannte Spalten" = Table.RenameColumns(Quelle,{{"requested_datetime", "Ticket eingegangen"}, {"updated_datetime", "letztes Ticketupdate"}}),
    #"Umbenannte Spalten1" = Table.RenameColumns(#"Umbenannte Spalten",{{"status_notes", "Aktivität Text Mitarbeiter"}, {"datetime", "Zeitstempel"}}),
    #"Hinzugefügte benutzerdefinierte Spalte" = Table.AddColumn(#"Umbenannte Spalten1", "Aktivität", each
        /* Aktivitäts-Mapping: siehe 01_aktivitaets_mapping.m */ ...),
    #"Umbenannte Spalten2" = Table.RenameColumns(#"Hinzugefügte benutzerdefinierte Spalte",{{"service_request_id", "Case_ID"}}),
    #"Entfernte Spalten2" = Table.RemoveColumns(#"Umbenannte Spalten2",{"Ticket eingegangen"}),
    #"Neu angeordnete Spalten" = Table.ReorderColumns(#"Entfernte Spalten2",{"Case_ID", "letztes Ticketupdate", "service_name", "description", "address", "zipcode", "lat", "long", "title", "Zeitstempel", "Aktivität Text Mitarbeiter", "Aktivität"}),
    #"Entfernte Spalten3" = Table.RemoveColumns(#"Neu angeordnete Spalten",{"Zeitstempel"}),
    #"Umbenannte Spalten3" = Table.RenameColumns(#"Entfernte Spalten3",{{"letztes Ticketupdate", "Zeitstempel"}}),
    #"Entfernte Spalten4" = Table.RemoveColumns(#"Umbenannte Spalten3",{"description", "address", "Aktivität Text Mitarbeiter", "Aktivität"}),
    #"Hinzugefügte benutzerdefinierte Spalte1" = Table.AddColumn(#"Entfernte Spalten4", "Aktivitäten", each "geschlossen"),
    #"Hinzugefügte benutzerdefinierte Spalte2" = Table.AddColumn(#"Hinzugefügte benutzerdefinierte Spalte1", "Synthethisch erstellt", each 1),
    #"Hinzugefügte benutzerdefinierte Spalte3" = Table.AddColumn(#"Hinzugefügte benutzerdefinierte Spalte2", "AktivitätenPriorität", each 99),
    #"Entfernte Duplikate" = Table.Distinct(#"Hinzugefügte benutzerdefinierte Spalte3", {"Case_ID"}),
    #"Geänderter Typ" = Table.TransformColumnTypes(#"Entfernte Duplikate",{{"Zeitstempel", type datetimezone}}),
    #"Entfernte Spalten" = Table.RemoveColumns(#"Geänderter Typ",{"status_name"}),
    #"Entfernte Duplikate1" = Table.Distinct(#"Entfernte Spalten", {"Case_ID"}),
    #"Umbenannte Spalten4" = Table.RenameColumns(#"Entfernte Duplikate1",{{"Synthethisch erstellt", "Synthetisch erstellt"}, {"Aktivitäten", "Aktivität"}})
in
    #"Umbenannte Spalten4"
