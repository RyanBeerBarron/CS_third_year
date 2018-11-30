import java.util.*;

public class Cache
{
	private final static int CACHE_BYTE_SIZE = 128;
	private final static int ADDRESS_LENGTH = 16;
	private final static int[] DATA = {	0x0000, 0x0004, 0x000c, 0x2200, 0x00d0, 0x00e0, 0x1130, 0x0028,
										0x113c, 0x2204, 0x0010, 0x0020, 0x0004, 0x0040, 0x2208, 0x0008,
										0x00a0, 0x0004, 0x1104, 0x0028, 0x000c, 0x0084, 0x000c, 0x3390,
										0x00b0, 0x1100, 0x0028, 0x0064, 0x0070, 0x00d0, 0x0008, 0x3394};
	private int k;
	private int n;
	private int l;
	private int tag_length;
	private int set_length;
	private CacheLine cache[][];

	public static int cacheHit;
	public static int cacheMiss;

	private class CacheLine
	{
		int size;
		int age;
		String tag;

		public CacheLine(int size)
		{
			this.tag = "";
			this.size = size;
			this.age = 0;
		}
	}

	public Cache(int k, int n, int l)
	{
		this.k = k;
		this.n = n;
		this.l = l;
		this.cache = new CacheLine[k][n];
		for(int i = 0; i < k; i++)
			for(int j = 0; j< n; j++)
				cache[i][j] = new CacheLine(l);
		this.set_length = log2(this.n);	
		this.tag_length = ADDRESS_LENGTH - set_length - log2(this.l);
	}

	public int retrieveCache(String address) 		// address is a string of bits.
	{
		String tag = address.substring(0, tag_length);	// string tag is the subtring of address from address[0] to addres [tag_length]
		int set = 0;
		if(this.set_length > 0)
			set = Integer.parseInt(address.substring(tag_length, tag_length+set_length), 2);	// Same thing for set except from address[tag_length] to address[tag_length+set_length]
		int i;
		for(i = 0; i<k; i++) 	// Compare all tags in the set of incoming address with the tag of incoming address
		{	
			String cacheTag = cache[i][set].tag;
			if(cacheTag.equals(tag))
			{
				cacheHit++;
				this.lruUpdate(i, set);		// if cache hit, increment counter and set age bit to 1 and increment others age bit accordingly
				i = k+1;
			}
		}	
		if(i == k)
		{
			cacheMiss++;
			this.lruMiss(tag, set);			// if cache miss, increment counter and add the tag in the oldest used cache line or a null one, set age bit to 1 and increment others age bit accordingly
		}	
		return 0;
	}

	private void lruUpdate(int k, int set)
	{
		int maxAge = this.cache[k][set].age;
		for(int i = 0; i<this.k; i++)
		{
			if(this.cache[i][set].age < maxAge && this.cache[i][set].age > 0)
				this.cache[i][set].age++;
		}	
		this.cache[k][set].age = 1;
	}

	private void lruMiss(String tag, int set)
	{
		int maxAge = this.k;
		for(int i = 0; i<this.k; i++)
		{
			if(this.cache[i][set].age == maxAge || this.cache[i][set].tag.equals(""))
			{
				this.cache[i][set].tag = tag;
				this.cache[i][set].age = maxAge;	
				this.lruUpdate(i, set);
				i = k;
			}	
		}			
	}

	public static int log2(int value)
	{
		int log2 = 0;
		while(value != 1)
		{
			value = value / 2;
			log2++;
		}	
		return log2;
	}

	public static String addressFill(String address)
	{
		String s = address;
		while(s.length() < ADDRESS_LENGTH)
			s = "0" + s;
		return s;
	}

	public static void main(String[] args)
	{
		if(args.length != 3)
			System.out.println("Error, please provide 3 arguments.");
		else
		{
			int k = Integer.parseInt(args[0]);
			int n = Integer.parseInt(args[1]);
			int l = Integer.parseInt(args[2]);
			cacheHit = 0;
			cacheMiss = 0;

			Cache cache = new Cache(k, n, l);
			for(int i = 0; i< DATA.length; i++)
			{
				cache.retrieveCache(addressFill(Integer.toBinaryString(DATA[i])));
			}	
			System.out.println("Number of cache hit: " + cacheHit);
			System.out.println("Number of cache miss: " + cacheMiss);
		}	
	}
}