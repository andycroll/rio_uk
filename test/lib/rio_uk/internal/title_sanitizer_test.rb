require_relative '../../../test_helper'

class RioUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_capitals_become_title_case
    assert_sanitized 'Fatherland', 'FATHERLAND'
    assert_sanitized 'I Love Boosters', 'I LOVE BOOSTERS'
    assert_sanitized 'Shaun the Sheep: The Beast of Mossy Bottom', 'SHAUN THE SHEEP: THE BEAST OF MOSSY BOTTOM'
    assert_sanitized "Pan's Labyrinth", "PAN'S LABYRINTH"
    assert_sanitized 'Spider-Man: Across the Spider-Verse', 'SPIDER-MAN: ACROSS THE SPIDER-VERSE'
  end

  def test_numbers_numerals_and_initialisms_keep_their_capitals
    assert_sanitized 'Final Destination 3', 'FINAL DESTINATION 3'
    assert_sanitized 'Rocky II', 'ROCKY II'
    assert_sanitized 'M3GAN', 'M3GAN'
    assert_sanitized 'RRR', 'RRR'
  end

  def test_mixed_case_titles_are_unchanged
    assert_sanitized 'Army of Lovers (or Revolt of the Perverts)', 'Army of Lovers (or Revolt of the Perverts)'
    assert_sanitized '10 Things I Hate About You', '10 Things I Hate About You'
    assert_sanitized 'Wallace & Gromit: A Grand Day Out', 'Wallace & Gromit: A Grand Day Out'
  end

  def test_strands_go
    assert_sanitized 'A Single Man', 'Pink Palace: A SINGLE MAN', strands: ['Pink Palace']
    assert_sanitized 'The Einstein of Sex', 'Pink Palace: The Einstein of Sex', strands: ['Pink Palace']
    assert_sanitized 'Flesh Gordon + Gums', 'Rio Forever Cult Lates: FLESH GORDON + GUMS', strands: ['Rio Forever']
  end

  def test_clubs_festivals_and_presenters_go
    assert_sanitized 'Your Name', 'JAPANESE FILM CLUB: YOUR NAME'
    assert_sanitized 'La Bola Negra', 'LONDON FESTIVAL OF QUEER SPANISH CULTURE: LA BOLA NEGRA'
    assert_sanitized 'A Short Film About Love', 'KINO POLONIA: A SHORT FILM ABOUT LOVE'
    assert_sanitized 'The Devils', 'Loose Willis presents: THE DEVILS'
    assert_sanitized 'Pozi', 'Velcro Flats presents POZI'
  end

  def test_mixed_case_prefixes_before_capitals_go
    assert_sanitized 'Malatesta’s Carnival of Blood + Final Destination 3',
                     'Category H: MALATESTA’S CARNIVAL OF BLOOD + FINAL DESTINATION 3'
    assert_sanitized 'Pan\'s Labyrinth', "Little White Lies: PAN'S LABYRINTH on 35mm"
  end

  def test_mixed_case_extras_after_capitals_go
    assert_sanitized 'Good Days: An Evening to Remember',
                     'World AIDS Day: GOOD DAYS: AN EVENING TO REMEMBER with Smut Press'
    assert_sanitized 'We, the Hated', 'WE, THE HATED (Just Stop Oil doc) + Q&A'
  end

  def test_q_and_a_goes
    assert_sanitized 'A Tribute to Mohammad Bakri', 'London Palestine Film Festival: A TRIBUTE TO MOHAMMAD BAKRI + Q&A'
  end

  def test_directors_go
    assert_sanitized 'Dao', "Black History Month: Alain Gomis' DAO", director: 'Alain Gomis'
    assert_sanitized 'The Devils', "Ken Russell's THE DEVILS", director: 'Ken Russell'
  end

  def test_event_cinema_names_are_kept_and_standardised
    assert_sanitized 'National Theatre Live: Hamlet', 'NT Live: HAMLET'
    assert_sanitized 'National Theatre Live: Hamlet', 'NT LIVE: HAMLET'
    assert_sanitized 'Royal Ballet and Opera: Swan Lake', 'RBO 2026-27: SWAN LAKE'
    assert_sanitized 'Exhibition on Screen: Turner', 'EXHIBITION ON SCREEN: TURNER'
  end

  private

  def assert_sanitized(expected, title, director: '', strands: [])
    assert_equal expected, RioUk::Internal::TitleSanitizer.new(title, director: director, strands: strands).sanitized
  end
end
