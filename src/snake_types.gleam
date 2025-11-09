import gleam/option
import tiramisu/asset

pub const box_width = 50.0

pub const highscore_key = "Highscore"

pub type Model {
  Model(
    time: Float,
    head: BoxData,
    tail: List(BoxData),
    beute_pos: #(Float, Float),
    update_frame: Int,
    game_state: GameState,
    maybe_font: option.Option(asset.Font),
    score: Int,
    highscore: option.Option(Int),
  )
}

pub type GameState {
  Running
  NotStarted
  GameOver
}

pub type BoxData {
  BoxData(x: Float, y: Float, direction: Direction)
}

pub type Direction {
  Right
  Left
  Up
  Down
}

pub type Msg {
  FontLoaded(asset.Font)
  FontLoadFailed(asset.LoadError)
  Tick
}

pub type FontLoading

pub type Color {
  BeuteColor
  SnakeHeadColor
  SnakeTailColor
  PrimeColor
  SecColor
  BorderColor
}

pub fn color_hex(color: Color) -> Int {
  case color {
    BeuteColor -> 0xfcba03
    SnakeHeadColor -> 0x34eb4c
    SnakeTailColor -> 0x42f5b6
    //red
    PrimeColor -> 0xeb0933
    BorderColor -> 0xeb4034
    // slight Blue
    SecColor -> 0x34d0eb
  }
}
