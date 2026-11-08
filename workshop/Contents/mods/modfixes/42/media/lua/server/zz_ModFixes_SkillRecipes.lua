-- Bug Zapper 9000 registers an older copy of xpUpdate.onLoad without the Inventive
-- trait bonus. This registers the vanilla function again.

if xpUpdate and xpUpdate.onLoadNew then
    Events.OnLoad.Remove(xpUpdate.onLoadNew)
    Events.OnLoad.Add(xpUpdate.onLoad)
end
