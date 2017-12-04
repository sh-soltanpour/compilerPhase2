public class SymbolTableReceiverItem extends SymbolTableItem {
  public SymbolTableReceiverItem(Receiver receiver, int offset) {
    this.receiver = receiver;
    this.offset = offset;
  }

  @Override
  public String getKey() {
    return receiver.getName();
  }

  public int getOffset() {
    return offset;
  }

  Receiver receiver;
  int offset;
}