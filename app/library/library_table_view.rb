class CMGLibraryTableView < UITableView
  def layoutSubviews
    frm = self.frame;
    sfrm = self.superview.frame;
    frm.size.width = sfrm.size.width - 30.0;
    frm.origin.x = 15.0;
    self.frame = frm;
    super
  end
end
