# intake schema design
intake tables should directly match their source endpoint's (from stats.nba.com) format. this is essential, as the data is inserted by a [Go program](https://github.com/jdetok/bball-etl-go), which expects the table format to match that of the JSON object it is attempting to insert
# player/wplayer
- player: nba players commonallplayer LeagueID=00
- wplayer: wnba players commonallplayer LeagueID=10
## differences between player/wplayer
- player has 16 cols, wplayer has 17
    - the first 14 columns of both tables are the same, but orders/fields are different after the `TEAM_ABBREVIATION` field
```sql
-- intake.player
    team_slug varchar(255),
    team_code varchar(255),
    games_played_flag varchar(1),
    otherleague_experience_ch varchar(10)

-- intake.wplayer
    team_code varchar(255),
    team_slug varchar(256),
    is_nba_assigned boolean,
    nba_assigned_team_id boolean,
    games_played_flag varchar(1)
```