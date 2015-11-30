import std.stdio;
import std.getopt;
import std.math;

void main(string[] args) {
  int maximum = 100;
  int segmentSize = 0;
  string filename = "stdout";
  
  getopt(args,
         "max|m", &maximum,
         "segment|s", &segmentSize,
         "file|f", &filename);
  
  if (segmentSize == 0) {
    segmentSize = cast(int) ceil(sqrt(cast(real) maximum));
  }
  if (segmentSize > maximum) {
    segmentSize = maximum;
  }
  if (segmentSize % 2 != 0) {
    ++segmentSize;
  }
  assert(maximum >= segmentSize && segmentSize > 0 && segmentSize % 2 == 0);

  int current = 3;
  int start = 3;
  int prevmax = 0;
  int segmax = segmentSize;
  int[] primes;
  bool[] candidates;
  candidates.length = segmentSize / 2;
  primes ~= 2;
  
  while (current < maximum) {
    candidates[] = true;
    //Eliminate multiples of confirmed primes
    foreach (prime; primes[1 .. $]) {
      int multiple = prevmax + prime - prevmax % prime;
      for (int i = multiple; i < segmax; i += prime) {
        if (i % 2 == 1) {
          candidates[(i - start - prevmax) / 2] = false;
        }
      }
    }
    //Enumerate multiples of potential primes
    while (current < segmax) {
      while (current < segmax && candidates[(current - start - prevmax) / 2] == false) {
        current += 2;
      }
      for (int i = current * 2; i < segmax; i += current) {
        if (i % 2 == 1) {
          candidates[(i - start - prevmax) / 2] = false;
        }
      }
      current += 2;
      if (current * 2 > segmax) {
        current = segmax + 1;
      }
    }
    //Append primes to the confirmed primes list
    for(int i = prevmax + start; i < segmax; i += 2) {
      if (candidates[(i - start - prevmax) / 2] == true) {
        primes ~= i;
      }
    }
    //Reset values for the next cycle
    prevmax = segmax;
    segmax += segmentSize;
    start = 1;
    if (segmax > maximum) {
      segmax = maximum;
    }
    current = prevmax;
  }

  if (filename == "stdout") {
    writeln(primes);
  } else {
    File output = File(filename, "w");
    output.write(primes[0]);
    foreach (prime; primes[1 .. $]) {
      output.write(", ", prime);
    }
  }
}
