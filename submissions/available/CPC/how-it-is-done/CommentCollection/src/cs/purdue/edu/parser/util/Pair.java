package cs.purdue.edu.parser.util;

public class Pair<F, S> {

	public final F first;
	public final S second;
	
	public Pair(F first, S second) {
	    this.first = first;
	    this.second = second;
	  }
		

	@Override
	public boolean equals(Object o) {
		if (!(o instanceof Pair)) return false;
		Pair pair = (Pair) o;
		return this.first.equals(pair.first) &&
				this.second.equals(pair.second);
	}

}
