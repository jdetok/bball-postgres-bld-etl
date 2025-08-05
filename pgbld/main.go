package main

import (
	"fmt"
	"log"
	"time"

	"github.com/jdetok/bball-etl-go/etl"
	"github.com/jdetok/golib/errd"
	"github.com/jdetok/golib/logd"
	"github.com/jdetok/golib/pgresd"
)

func main() {
	// start time variable for logging
	var sTime time.Time = time.Now()

	/*
		// SET START AND END SEASONS
		var st string = "1970"
		var en string = time.Now().Format("2006") // current year
	*/
	// Conf variable, hold logger, db, etc
	var cnf etl.Conf

	e := errd.InitErr() // start error handler

	// initialize logger
	l, err := logd.InitLogger("z_log", "nightly_etl")
	if err != nil {
		e.Msg = "error initializing logger"
		log.Fatal(e.BuildErr(err))
	}
	cnf.L = l // assign to cnf

	// postgres connection
	pg := pgresd.GetEnvPG()
	pg.MakeConnStr()
	db, err := pg.Conn()
	if err != nil {
		e.Msg = "error connecting to postgres"
		cnf.L.WriteLog(e.Msg)
		log.Fatal(e.BuildErr(err))
	}

	cnf.DB = db // asign to cnf
	cnf.DB.SetMaxOpenConns(40)
	cnf.DB.SetMaxIdleConns(40)
	cnf.RowCnt = 0 // START ROW COUNTER AT 0 BEFORE ETL STARTS

	if err = etl.RunNightlyETL(cnf); err != nil {
		e.Msg = fmt.Sprintf(
			"error with %v nightly etl", etl.Yesterday(time.Now()))
		cnf.L.WriteLog(e.Msg)
		log.Fatal(e.BuildErr(err))
	}
	/*
		if err = RunSeasonETL(cnf, st, en); err != nil {
			e.Msg = fmt.Sprintf(
				"error running season etl: start year: %s | end year: %s", st, en)
			cnf.L.WriteLog(e.Msg)
			log.Fatal(e.BuildErr(err))
		}
	*/
	// write errors to the log
	if len(cnf.Errs) > 0 {
		cnf.L.WriteLog(fmt.Sprintln("ERRORS:"))
		for _, e := range cnf.Errs {
			cnf.L.WriteLog(fmt.Sprintln(e))
		}
	}

	// email log file to myself
	EmailLog(cnf.L)
	if err != nil {
		e.Msg = "error emailing log"
		cnf.L.WriteLog(e.Msg)
		log.Fatal(e.BuildErr(err))
	}
	/*
		// log SEASON process complete
			cnf.L.WriteLog(
				fmt.Sprint(
					"process complete",
					fmt.Sprintf(
						"\n ---- start time: %v", sTime),
					fmt.Sprintf(
						"\n ---- cmplt time: %v", time.Now()),
					fmt.Sprintf(
						"\n ---- duration: %v", time.Since(sTime)),
					fmt.Sprintf(
						"\n---- etl for seasons between %s and %s | total rows affected: %d",
						st, en, cnf.RowCnt,
					),
				),
			)*/
	// log NIGHTLY process complete
	cnf.L.WriteLog(
		fmt.Sprint(
			"process complete",
			fmt.Sprintf(
				"\n ---- start time: %v", sTime),
			fmt.Sprintf(
				"\n ---- cmplt time: %v", time.Now()),
			fmt.Sprintf(
				"\n ---- duration: %v", time.Since(sTime)),
			fmt.Sprintf(
				"\n---- nightly etl for %v complete | total rows affected: %d",
				etl.Yesterday(time.Now()), cnf.RowCnt,
			),
		),
	)
}

/*
	// CREATE SLICE OF SEASONS FROM START/END YEARS
	szns, err := SznBSlice(l, st, en)
	if err != nil {
		e.Msg = "error making seasons string"
		cnf.L.WriteLog(e.Msg)
		log.Fatal(e.BuildErr(err))
	}

	cnf.RowCnt = 0 // START ROW COUNTER AT 0 BEFORE ETL STARTS
	// run ETL (http request, clean data, insert into db) for each season
	for _, s := range szns {
		sra := cnf.RowCnt // capture row count at start of each season
		stT := time.Now()

		// players etl for season
		if err := SznPlayersETL(cnf, "1", s); err != nil {
			e.Msg = fmt.Sprint("error getting players for ", s)
			cnf.L.WriteLog(e.Msg)
			fmt.Println(e.BuildErr(err))
		}

		// get team and player game logs for the season
		err = GLogSeasonETL(&cnf, s)
		if err != nil {
			e.Msg = fmt.Sprint("error inserting data for ", s)
			cnf.L.WriteLog(e.Msg)
			fmt.Println(e.BuildErr(err))
		} // log finished with season etl
		cnf.L.WriteLog(fmt.Sprint(
			fmt.Sprintf("====  finished with %s season ETL after %v",
				s, time.Since(stT)),
			fmt.Sprintf(
				"\n== total rows before: %d | total rows after: %d",
				sra, cnf.RowCnt),
			fmt.Sprintf(
				"\n== rows affected from %s fetch: %d", s, cnf.RowCnt-sra),
			fmt.Sprintf(
				"\n== total rows affected: %d", cnf.RowCnt)))
	} // log finished with ETL
	cnf.L.WriteLog(fmt.Sprintf(
		"\n====  finished %d seasons between %s and %s | total rows affected: %d",
		len(szns), st, en, cnf.RowCnt,
	))
*/

/*
	if err := CrntPlayersETL(l, db, "1"); err != nil {
		e.Msg = "error getting players"
		l.WriteLog(e.Msg)
		log.Fatal(e.BuildErr(err))
	}
*/
// fetch & insert current (as of yesterday) stats for NBA and WNBA
// err = GLogDailyETL(l, db)

// err = GLogSeasonETL(cnf, SZN)
// if err != nil {
// 	e.Msg = "error inserting data"
// 	l.WriteLog(e.Msg)
// 	log.Fatal(e.BuildErr(err))
// }

// }
