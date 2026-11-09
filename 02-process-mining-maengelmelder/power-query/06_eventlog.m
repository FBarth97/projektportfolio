// Abfrage: Eventlog
// Zusammenführung von Start-, realen und End-Events, Sortierung nach Case-ID, Zeitstempel und Priorität, Event-Index je Fall.
// Quelle "Tabelle92" = zusammengeführte API-Rohdaten im Excel-Workbook.

Eventlog = let
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
    #"Entfernte Duplikate1" = Table.Distinct(#"Entfernte Spalten", {"Case_ID"}),
    #"Angefügte Abfrage" = Table.Combine({#"Entfernte Duplikate1", Events_real, Events_geschlossen}),
    #"Sortierte Zeilen" = Table.Sort(#"Angefügte Abfrage",{{"Case_ID", Order.Ascending}, {"Zeitstempel", Order.Ascending}, {"AktivitätenPriorität", Order.Ascending}}),
    #"Gruppierte Zeilen" = Table.Group(#"Sortierte Zeilen", {"Case_ID"}, {{"AlleEvents", each _, type table [Case_ID=text, Zeitstempel=nullable datetimezone, service_name=text, zipcode=text, lat=number, long=number, title=any, Aktivität=text, Synthetisch erstellt=number, AktivitätenPriorität=number]}}),
    #"Hinzugefügte benutzerdefinierte Spalte4" = Table.AddColumn(#"Gruppierte Zeilen", "EventtabellenIndex", each Table.AddIndexColumn([AlleEvents], "EventIndex", 1, 1, Int64.Type)),
    #"Entfernte Spalten1" = Table.RemoveColumns(#"Hinzugefügte benutzerdefinierte Spalte4",{"AlleEvents"}),
    #"Erweiterte EventtabellenIndex" = Table.ExpandTableColumn(#"Entfernte Spalten1", "EventtabellenIndex", {"Case_ID", "Zeitstempel", "service_name", "zipcode", "lat", "long", "title", "Aktivität", "Synthetisch erstellt", "AktivitätenPriorität", "EventIndex"}, {"Case_ID.1", "Zeitstempel", "service_name", "zipcode", "lat", "long", "title", "Aktivität", "Synthetisch erstellt", "AktivitätenPriorität", "EventIndex"}),
    #"Entfernte Spalten2" = Table.RemoveColumns(#"Erweiterte EventtabellenIndex",{"Case_ID.1"}),
    #"Geänderter Typ1" = Table.TransformColumnTypes(#"Entfernte Spalten2",{{"Zeitstempel", type datetimezone}, {"Case_ID", type text}, {"service_name", type text}, {"zipcode", type text}, {"title", type text}, {"Aktivität", type text}})
in
    #"Geänderter Typ1"
