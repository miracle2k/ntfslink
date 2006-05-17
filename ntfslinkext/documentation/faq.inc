<p>
  <span style="font-weight: bold">After the installation, is it really necessary that I restart?</span><br />
  No. Logging off should be enough, however, this is currently not supported by the Setup tool I use.
</p>

<p>
  <span style="font-weight: bold">What's the difference between a hard link and a junction? I don't get this..</span><br />
  A really good introduction to hard links and junctions, which explains everything from the very beginning, was published
  on <a href="http://shell-shocked.org/article.php?id=284">Shell-Shocked</a>.
</p>

<p>
  <span style="font-weight: bold">So, how can I create links using the Windows Explorer?</span><br />
  NTFS Link currently offers a couple of possibilities to create links:
  <ul>
    <li>The one mostly used is hidden in the Drag&Drop menu.
        Just drag a file using the <em>right</em> mouse button, and drop it somewhere else. A menu will popup, into
        which NTFS Link has integrated.</li>
    <li>You can use the Explorer-New-Menu. Right-click on an empty place somewhere in any explorer window or
        on the Desktop, and choose <em>New</em>. In its submenu, there are two items, titled <em>"NTFS Hardlink"</em>
        and <em>"NTFS Junction Point"</em>.</li>
    <li>A third features allows you to convert an <em>empty</em> (!) folder into a junction. Just right-click on it,
        and choose <em>"NTFS Link | Link Folder"</em> from the menu.</li>
  </ul>
</p>

<p>
  <span style="font-weight: bold">Do I have to expect any issues when deleting links?</span><br />
  For hard links definitely not. However, Windows Explorer has no idea how to handle junction points. Normally,
  if you would delete a junction, all the content of the target folder would be deleted as well. To fix this,
  NTFS Link intercepts the deletion of folders, and makes sure that junctions are correctly processed.<br />
  If you want to make absolutely sure that nothing can happen to your data, right-click on the junction point
  and choose <em>"NTFS Link | Unlink Folder"</em>, before deleting it.
</p>

<p>
  <span style="font-weight: bold">What does this "junction tracking" thing in the configuration utility mean?</span><br />
  If you delete, move or rename the target folder of a junction, the junction will stop working. As there is no build-in
  functionality in Windows to find the junctions pointing to a folder, NTFS Link tries to keep track of that itself (if
  you create a junction using some other, external utility, NTFS Link will of course not know about it).<br />
  There are two different how this information can be stored: The best solution is "NTFS streams". Basically,
  what it does is attaching additional data to the directories you create links to. No, the problem here is, that streams
  are not supported on FAT drives. To work around that issue, NTFS Link can alternatively use the Registry to save
  the tracking data.
</p>

<p>
  <span style="font-weight: bold">I found a bug / I have a feature request. What should I do?</span><br />
  Post them to the appropriate trackers in
  <a href="http://forge.novell.com/modules/xfmod/project/?ntfslink">Novell Forge</a>.
  Click on the <em>"Submit New"</em>
  on the top to post a new entry.
</p>
