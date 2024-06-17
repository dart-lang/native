import androidx.annotation.Keep
import kotlinx.coroutines.*
import java.lang.ArithmeticException

@Keep
class Example {
  public suspend fun thinkBeforeAnswering(): String {
    delay(1000L)
    return "42"
  }
}

interface Divider {
  fun divide(a: Int, b: Int): Int
}

class DividerUser {
  fun useDivider(divider: Divider, a: Int, b: Int): Int {
    try{
      return divider.divide(a, b)
    } catch (e: ArithmeticException) {
      return 0
    }
  }
}
