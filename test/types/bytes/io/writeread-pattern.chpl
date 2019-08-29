config const nRepeat = 10;

proc test(byteRange) {
  const byteRange = 0..255;
  const reverseRange = byteRange by -byteRange.stride;
  const nBytes = (byteRange.size + reverseRange.size)*nRepeat;
  var buf = c_malloc(uint(8), nBytes+1);

  var i = 0;
  for r in 0..#nRepeat {
    for b in byteRange {
      buf[i] = b:uint(8);
      i += 1;
    }
    for b in reverseRange {
      buf[i] = b:uint(8);
      i += 1;
    }
  }
  buf[nBytes] = 0;

  const randomBytes = new bytes(buf, length=nBytes, size=nBytes+1,
                                isowned=true, needToCopy=false);

  if randomBytes.length != nBytes {
    halt("Error creating bytes object with correct length");
  }

  var bytesChannel = opentmp();

  {
    // write them to a channel
    var bytesWriter = bytesChannel.writer();
    bytesWriter.writef("%ht", randomBytes);
    bytesWriter.close();
  }

  {
    // read them into a different object
    var bytesReader = bytesChannel.reader();
    var readBytes = b"";
    bytesReader.readf("%ht", readBytes);
    bytesReader.close();
    // compare
    if readBytes == randomBytes {
      writeln("Success");
    }
    else {
      writeln("Failed: Bytes generated and read differ!");
    }
  }

  {
    // write them to a channel
    var bytesWriter = bytesChannel.writer();
    bytesWriter.writef("%|*s", randomBytes.length, randomBytes);
    bytesWriter.close();
  }

  {
    // read them into a different object
    var bytesReader = bytesChannel.reader();
    var readBytes = b"";
    var readLen = randomBytes.length;
    bytesReader.readf("%|*s", readLen, readBytes);
    bytesReader.close();
    // compare
    if readBytes == randomBytes {
      writeln("Success");
    }
    else {
      writeln("Failed: Bytes generated and read differ!");
    }
  }


}

test(0..255);
test(0..255 by 5);
test(0..255 by 7);
test(0..10);