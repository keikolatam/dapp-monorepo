---
inclusion: manual
---

# Context7 Integration for Keiko Development Stack

This steering file provides access to the latest documentation for our complete Rust development stack through Context7 MCP.

## Usage

When working with any component of our Rust stack (Substrate, GraphQL, or web frontend), use the Context7 MCP to get up-to-date documentation and examples from the official repositories.

## Context7 Library Information

### Polkadot SDK (Backend - Parachain)

- **Library URL**: https://context7.com/paritytech/polkadot-sdk
- **Library ID**: `/paritytech/polkadot-sdk`
- **Coverage**: Complete Polkadot SDK documentation including:
  - FRAME pallets and macros
  - Substrate runtime development
  - Trait implementations and derives
  - Latest API changes and updates
  - Best practices and examples

### Juniper (Middleware - GraphQL Server)

- **Library URL**: https://context7.com/graphql-rust/juniper
- **Library ID**: `/graphql-rust/juniper`
- **Coverage**: Complete Juniper GraphQL documentation including:
  - Schema definition with derive macros
  - Query and Mutation resolvers
  - Context and dependency injection
  - Integration with web frameworks (Axum, Actix, etc.)
  - Type-safe GraphQL development
  - Subscription handling
  - Error handling patterns

### Leptos (Admin Panel - Web Frontend)

- **Library URL**: https://context7.com/leptos-rs/leptos
- **Library ID**: `/leptos-rs/leptos`
- **Coverage**: Complete Leptos web framework documentation including:
  - Server-Side Rendering (SSR) and Client-Side Rendering (CSR)
  - Reactive signals and state management
  - Component development with view! macro
  - Leptos Router for navigation
  - Server functions and hydration
  - Integration with web servers (Axum, Actix)
  - Progressive Web App capabilities

### Cristalyse (Flutter - Data Visualization)

- **Library URL**: https://context7.com/rudi-q/cristalyse
- **Library ID**: `/rudi-q/cristalyse`
- **Coverage**: Complete Cristalyse data visualization library for Flutter including:
  - Interactive charts and graphs for learning analytics
  - Timeline visualizations for learning progress
  - Statistical data representation
  - Customizable chart components
  - Real-time data visualization
  - Educational dashboard components
  - Learning metrics visualization

## Common Use Cases

### Polkadot SDK / Substrate

1. **Trait Implementation Issues**: When encountering missing trait implementations like `DecodeWithMemTracking`
2. **Pallet Development**: Understanding FRAME pallet structure and macros
3. **Runtime Configuration**: Setting up runtime configurations properly
4. **API Updates**: Checking for breaking changes or new requirements in latest versions

### Juniper GraphQL

1. **Schema Design**: Creating type-safe GraphQL schemas with derive macros
2. **Resolver Implementation**: Writing async resolvers with proper error handling
3. **Context Management**: Setting up dependency injection and database access
4. **Integration Issues**: Connecting Juniper with Axum/Actix web servers
5. **Performance Optimization**: Implementing efficient queries and mutations

### Leptos Web Framework

1. **Component Development**: Creating reactive components with signals
2. **SSR/CSR Setup**: Configuring server-side and client-side rendering
3. **State Management**: Using signals, resources, and global state
4. **Routing**: Implementing navigation with Leptos Router
5. **Server Functions**: Creating full-stack functionality with server functions
6. **Hydration Issues**: Resolving client-side hydration problems

### Cristalyse Data Visualization

1. **Learning Analytics**: Creating interactive charts for learning progress and performance
2. **Timeline Visualization**: Implementing timeline components for learning passport display
3. **Statistical Charts**: Building charts for reputation scores, learning metrics, and trends
4. **Dashboard Components**: Creating educational dashboards with multiple data visualizations
5. **Real-time Updates**: Implementing live data visualization for active learning sessions
6. **Custom Chart Types**: Creating specialized visualizations for educational data

## Integration with Development

This Context7 integration should be used whenever:

### Backend Development (Substrate)

- Encountering compilation errors related to Substrate/Polkadot SDK
- Implementing new pallets or runtime features
- Updating existing code to newer SDK versions
- Understanding best practices for Substrate development

### Middleware Development (Juniper)

- Setting up GraphQL schemas and resolvers
- Integrating with Substrate parachain via substrate-api-client
- Implementing authentication and authorization
- Optimizing GraphQL query performance
- Handling complex data relationships

### Admin Panel Development (Leptos)

- Creating reactive web interfaces for administration
- Implementing CRUD operations for user management
- Setting up SSR for SEO and initial load performance
- Managing complex form state and validation
- Integrating with GraphQL APIs from the client side

### Flutter Frontend Development (Cristalyse)

- Creating interactive learning analytics dashboards
- Implementing timeline visualizations for learning passports
- Building statistical charts for reputation and progress tracking
- Developing real-time data visualization for active sessions
- Creating custom educational data visualization components
- Integrating charts with GraphQL data sources

### Cross-Stack Integration

- Connecting Flutter frontend to GraphQL middleware
- Ensuring type safety across the entire stack
- Implementing real-time features with subscriptions
- Managing authentication across all layers

The Context7 MCP provides access to the most current documentation and can help resolve issues that may not be covered in older documentation or tutorials. Always prefer Context7 documentation over potentially outdated online resources.
