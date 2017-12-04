public class ArrayType extends Type {
	ArrayType (Type type , int width ){
        this.type = type;
        this.width = width;
    }
	public int size() {
		return width * type.size();
	}
	@Override
	public boolean equals(Object other) {
		if(other instanceof ArrayType && type.equals(((ArrayType)other).getType()))
			return true;
		return false;
	}

	@Override
	public String toString() {
		return "Array of" + type.toString();
    }
    public Type getType(){
        return type;
    }

	private static ArrayType instance;

    Type type;
    int width;

}