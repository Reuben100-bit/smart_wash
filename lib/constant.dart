import 'dimensions.dart';
import 'dart:developer' as dev;

final d = Dimensions();


String homeInfo =
    "60%+ University students face anxiety, 40%+ experience depression during the academic year. Mental health care is vital for growth and academic success.";

lg(String value) {
  dev.log(value);
}


String homeIcon = r"""
<svg xmlns="http://www.w3.org/2000/svg" width="42" height="38" viewBox="0 0 42 38" fill="none">
<path opacity="0.76" d="M34.2145 12.7132L40.5809 18.7302C41.3502 19.4676 41.1306 20.036 40.0874 20.036H35.3121V35.7568C35.3121 36.8356 34.434 37.8 33.3908 37.8H25.103V26.7885C25.103 25.7097 24.1704 24.7453 23.1272 24.7453H17.9128C16.8696 24.7453 15.937 25.7097 15.937 26.7885V37.8H7.64921C6.60599 37.8 5.67341 36.8356 5.67341 35.7568V20.036H0.952574C-0.090648 20.036 -0.310181 19.4676 0.459063 18.7302L19.0649 1.24953C19.8342 0.512161 21.1514 0.512161 21.9733 1.24953L26.1989 5.16519V2.04319C26.1989 0.964388 27.1315 0 28.1747 0H32.2914C33.3346 0 34.2127 0.964388 34.2127 2.04319L34.2145 12.7132Z" fill="black"/>
</svg>
""";