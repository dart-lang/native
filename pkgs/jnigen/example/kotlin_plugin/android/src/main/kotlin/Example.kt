import androidx.annotation.Keep
import kotlinx.coroutines.*

@Keep
class Example {
  public suspend fun thinkBeforeAnswering(): String {
    delay(1000L)
    return "42"
  }
}
