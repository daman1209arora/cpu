import java.io.*;
public class TestGenerator{
	public static String toBinary(int n, int digits){
		char[] s = new char[digits];
		for(int i = 0; i < digits; i++)
			s[i] = '0';
		int idx = 0;
		while(n != 0){
			if(n % 2 == 0)
				s[digits - idx - 1] = '0';
			else
				s[digits - idx - 1] = '1';
			n /= 2;
			idx++;
		}
		return new String(s);
	}
	public static void main(String[] args)throws IOException{
		BufferedReader br = new BufferedReader(new FileReader(new File(args[0])));
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File(args[1])));
		bw.write("radix = 2\n");
		bw.write("memory_initialization_radix = 2\n");
		bw.write("memory_initialization_vector = \n");
		String s;
		String[] prog = new String[4096];
		
		for(int i = 0; i < 4096; i++)
			prog[i] = "00000000000000000000000000000000";

		int i = 0;
		while(!(s = br.readLine()).equals("")){
			String[] tokens = s.split("-");
			int idx = Integer.parseInt(tokens[0]);
			String val = toBinary(Integer.parseInt(tokens[1]), 32);

			prog[idx] = val;
		}

		while((s = br.readLine()) != null){
			String[] tokens = s.split(" ");
			String instr = null;
			if(tokens[0].compareTo("add") == 0){
				int to = Integer.parseInt(tokens[1]);
				int f1 = Integer.parseInt(tokens[2]);
				int f2 = Integer.parseInt(tokens[3]);
				instr = "000000";
				instr += toBinary(f1, 5);
				instr += toBinary(f2, 5);
				instr += toBinary(to, 5);
				instr += "00000";
				instr += "100000";
			}
			else if(tokens[0].compareTo("sub") == 0){
				int to = Integer.parseInt(tokens[1]);
				int f1 = Integer.parseInt(tokens[2]);
				int f2 = Integer.parseInt(tokens[3]);
				instr = "000000";
				instr += toBinary(f1, 5);
				instr += toBinary(f2, 5);
				instr += toBinary(to, 5);
				instr += "00000";
				instr += "100010";
			}
			else if(tokens[0].compareTo("sll") == 0){
				int to = Integer.parseInt(tokens[1]);
				int from = Integer.parseInt(tokens[2]);
				int amt = Integer.parseInt(tokens[3]);
				instr = "000000";
				instr += "00000";
				instr += toBinary(from, 5);
				instr += toBinary(to, 5);
				instr += toBinary(amt, 5);
				instr += "000000";
			}
			else if(tokens[0].compareTo("srl") == 0){
				int to = Integer.parseInt(tokens[1]);
				int from = Integer.parseInt(tokens[2]);
				int amt = Integer.parseInt(tokens[3]);
				instr = "000000";
				instr += "00000";
				instr += toBinary(from, 5);
				instr += toBinary(to, 5);
				instr += toBinary(amt, 5);
				instr += "000010";
			}
			else if(tokens[0].compareTo("sw") == 0){
				int from = Integer.parseInt(tokens[1]);
				int offset = Integer.parseInt(tokens[2]);
				instr = "101011";
				instr += "00000";
				instr += toBinary(from, 5);
				instr += toBinary(offset, 16);
			}
			else if(tokens[0].compareTo("lw") == 0){
				int to = Integer.parseInt(tokens[1]);
				int offset = Integer.parseInt(tokens[2]);
				instr = "100011";
				instr += "00000";
				instr += toBinary(to, 5);
				instr += toBinary(offset, 16);
			}
			else
				System.out.println("Invalid program");
			prog[i] = instr;
			i++;
		}

		for(int j = 0; j < 4096; j++){
			if(j == 4095)
				bw.write(prog[j] + ";\n");
			else
				bw.write(prog[j] + ",\n");
		}

		br.close();
		bw.close();
	}
}