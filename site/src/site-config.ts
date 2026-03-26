import type { SiteConfig } from '@mcptoolshop/site-theme';

export const config: SiteConfig = {
  title: 'Star Freight Client',
  description: 'Godot 4.6 graphical client for the Star Freight space merchant RPG — renders crew, creatures, and hostiles using pixel sprite packs via JSON-RPC engine bridge.',
  logoBadge: 'SF',
  brandName: 'Star Freight Client',
  repoUrl: 'https://github.com/mcp-tool-shop-org/star-freight-client',
  footerText: 'MIT Licensed — built by <a href="https://mcp-tool-shop.github.io/" style="color:var(--color-muted);text-decoration:underline">MCP Tool Shop</a>',

  hero: {
    badge: 'Godot 4.6',
    headline: 'Star Freight',
    headlineAccent: 'graphical client.',
    description: 'Pixel sprite rendering surface for the Star Freight space merchant RPG. Python engine stays authoritative — Godot renders what the engine tells it.',
    primaryCta: { href: '#architecture', label: 'See how it works' },
    secondaryCta: { href: 'handbook/', label: 'Read the Handbook' },
    previews: [
      { label: 'Run', code: 'Open in Godot 4.6 → Press F5' },
      { label: 'Bridge', code: 'starfreight rpc  # Python engine serves state via JSON-RPC' },
      { label: 'Import', code: 'python scripts/import_packs.py --subjects sera_vale,thal' },
    ],
  },

  sections: [
    {
      kind: 'features',
      id: 'features',
      title: 'Features',
      subtitle: 'A thin, focused rendering client.',
      features: [
        { title: 'Sprite Packs', desc: '8-direction pixel sprites with albedo, normal, and depth maps. 48×48 transparent PNGs loaded via manifest.json.' },
        { title: 'Engine Bridge', desc: 'JSON-RPC 2.0 over stdio. Godot spawns the Python engine as a subprocess — turn-based latency is invisible.' },
        { title: 'Normal Lighting', desc: 'CanvasTexture combines albedo + normal maps for dynamic point light rendering on 2D sprites.' },
      ],
    },
    {
      kind: 'code-cards',
      id: 'architecture',
      title: 'Architecture',
      cards: [
        {
          title: 'Two-repo split',
          code: `star-freight (Python)        star-freight-client (Godot)
┌─────────────────┐          ┌────────────────────────┐
│ portlight.engine │─JSON-RPC─│ engine_bridge.gd       │
│ portlight.rpc    │ (stdio)  │ pack_loader.gd         │
│ portlight.content│          │ character_node.gd      │
└─────────────────┘          │ assets/characters/     │
                              └────────────────────────┘`,
        },
        {
          title: 'RPC contract',
          code: `ping          → { status, version }
get_roster    → { crew: [...], count }
get_crew_member → crew member dict
get_campaign  → campaign summary
shutdown      → { status }`,
        },
      ],
    },
  ],
};
