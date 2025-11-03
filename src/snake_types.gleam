pub const box_width = 50.0

pub type Model {
  Model(
    time: Float,
    head: BoxData,
    tail: List(BoxData),
    beute_pos: #(Float, Float),
    update_frame: Int,
    game_state: GameState,
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
  Tick
}
