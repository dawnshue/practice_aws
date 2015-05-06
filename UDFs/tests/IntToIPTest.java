package org.cafemom.udf;
import org.junit.Assert.*;
import org.junit.Test;
import org.apache.hadoop.io.Text;
import org.junit.Test;

public class IntToIPTest {

	@Test
	public void testUDF() {
		IntToIP example = new IntToIP();
		assertEquals("38.88.255.14", example.evaluate(new Text("643366670")).toString());
	}

	@Test
	public void testNullCheck() {
		IntToIP example = new IntToIP();
		assertNull(example.evaluate(null));
	}
	
	@Test
	public void testTrimCheck() {
		IntToIP example = new IntToIP();
		assertEquals("38.88.255.14", example.evaluate(new Text(" 643366670  ")).toString());
	}
	
	@Test
	public void testBadStringCheck() {
		IntToIP example = new IntToIP();
		assertNull(example.evaluate(new Text("643366670asdfasdf")).toString());
	}

}
