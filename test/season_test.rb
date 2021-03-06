require './test/test_helper'
require './lib/season'
require './lib/stat_tracker'

class SeasonTest < Minitest::Test

  def setup
    game_path = './test/fixtures/games_sample.csv'
    team_path = './test/fixtures/teams_sample.csv'
    game_teams_path = './test/fixtures/game_teams_sample.csv'

    @locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    @stat_tracker = StatTracker.from_csv(@locations)
    @season = @stat_tracker.season_data[0]
  end

  def test_it_finds_all_seasons
    assert_equal 6, Season.all.length
    assert_equal @season, Season.all[0]
  end

  def test_it_finds_unique_seasons
    expected = ["20172018", "20132014", "20122013", "20142015", "20162017", "20152016"]

    assert_equal expected, Season.find_unique_seasons(@stat_tracker.games_data)
  end

  def test_it_finds_single_seasons
    expected = @stat_tracker.season_data[0]

    assert_equal expected, Season.find_single_season("20172018")
  end

  def test_it_finds_season_games
    game_path = './test/fixtures/games_smaller_sample.csv'
    team_path = './test/fixtures/teams_sample.csv'
    game_teams_path = './test/fixtures/game_teams_smaller_sample.csv'
    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.from_csv(locations)

    expected = [stat_tracker.games_data[3], stat_tracker.games_data[5]]

    assert_equal expected, Season.find_season_games(stat_tracker.games_data, "20122013")
  end

  def test_it_finds_season_game_ids
    game_path = './test/fixtures/games_smaller_sample.csv'
    team_path = './test/fixtures/teams_sample.csv'
    game_teams_path = './test/fixtures/game_teams_smaller_sample.csv'
    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.from_csv(locations)

    season_game_data = Season.find_season_games(stat_tracker.games_data, "20172018")
    expected = ["2017030113", "2017030114"]

    assert_equal expected, Season.find_season_game_ids(season_game_data)
  end

  def test_it_finds_season_game_teams
    game_path = './test/fixtures/games_smaller_sample.csv'
    team_path = './test/fixtures/teams_sample.csv'
    game_teams_path = './test/fixtures/game_teams_smaller_sample.csv'
    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.from_csv(locations)

    season_game_data = Season.find_season_games(stat_tracker.games_data, "20172018")
    expected = [stat_tracker.game_teams_data[6], stat_tracker.game_teams_data[7]]

    assert_equal expected, Season.find_season_game_teams(stat_tracker.game_teams_data, season_game_data)
  end

  def test_it_finds_most_accurate_team_id
    assert_equal 2, Season.most_accurate_team("20172018")
  end

  def test_it_finds_least_accurate_team_id
    assert_equal 1, Season.least_accurate_team("20172018")
  end

  def test_it_finds_team_id_with_most_tackles
    assert_equal 1, Season.most_tackles("20172018")
  end

  def test_it_finds_team_id_with_least_tackles
    assert_equal 2, Season.fewest_tackles("20172018")
  end

  def test_it_finds_winningest_coach
    assert_equal "John Hynes", Season.winningest_coach("20172018")
  end

  def test_it_finds_losingest_coach
    assert_equal "Doug Weight", Season.worst_coach("20172018")
  end

  def test_it_exists
    assert_instance_of Season, @season
  end

  def test_it_has_attributes
    game_path = './test/fixtures/games_smaller_sample.csv'
    team_path = './test/fixtures/teams_sample.csv'
    game_teams_path = './test/fixtures/game_teams_smaller_sample.csv'
    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.from_csv(locations)
    season = stat_tracker.season_data[0]

    expected_game_data = Season.find_season_games(stat_tracker.games_data, "20172018")
    expected_game_team_data = Season.find_season_game_teams(stat_tracker.game_teams_data, expected_game_data)

    assert_equal "20172018", season.season_name
    assert_equal expected_game_data[0].game_id, season.game_data[0].game_id
    assert_equal expected_game_team_data[0].game_id, season.game_teams_data[0].game_id
    assert_equal expected_game_data.size, season.game_data.size
    assert_equal expected_game_team_data.size, season.game_teams_data.size
  end

  def test_it_calculates_win_count
    assert_equal 1, @season.win_count("WIN")
    assert_equal 0, @season.win_count("TIE")
    assert_equal 0, @season.win_count("LOSS")

  end

  def test_it_creates_season_data_report
    expected = {2=>
      {"Regular Season"=>
        {:wins=>15,
        :games=>43,
        :tackles=>900,
        :shots=>331,
        :goals=>103}},
      1=>
        {"Postseason"=>
          {:wins=>1,
          :games=>2,
          :tackles=>58,
          :shots=>17,
          :goals=>4},
          "Regular Season"=>
            {:wins=>17,
            :games=>43,
            :tackles=>953,
            :shots=>334,
            :goals=>94}}
      }
    assert_equal expected, @season.season_data_report
  end

  def test_it_calculates_win_percentage
    assert_equal Hash, @season.win_percentage("Regular Season").class
    assert_equal 0.40, @season.win_percentage("Regular Season")[1].round(2)
    assert_equal 0.5, @season.win_percentage("Postseason")[1].round(2)
  end

  def test_it_calculates_win_percentage_difference_between_season_types
    assert_equal (-0.10), @season.win_percentage_diff_between_season_types[1].round(2)
  end

  def test_it_finds_team_id_with_biggest_bust
    assert_equal 2, Season.biggest_diff_id("20152016", 'bust')
  end

  def test_it_finds_the_team_id_with_the_biggest_surprise
    assert_equal 2, Season.biggest_diff_id("20152016", 'surprise')
  end

  def test_it_looks_up_team_name
    assert_equal "Atlanta United", Season.find_team_name(1)
    assert_equal "Seattle Sounders FC",  Season.find_team_name(2)
  end

end
