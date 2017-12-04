public class Tools {

  static public void putActor(String name, int mailboxSize) throws ItemAlreadyExistsException {
    SymbolTable.top.put(new SymbolTableActorItem(new Actor(name, mailboxSize), SymbolTable.top.getOffset(Register.GP)));
  }

}