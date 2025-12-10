import androidx.annotation.Keep
import kotlin.*
import kotlin.coroutines.*
import kotlinx.coroutines.*

@Keep
interface Thinker {
  public suspend fun message(): String
}

@Keep
class Example {
  public suspend fun thinkBeforeAnswering(thinker: Thinker): String {
    delay(1000L)
    return "Kotlin[" + thinker.message() + ']'
  }
}
