import { BkashAdapter } from './bkash.adapter.js';
import { NagadAdapter } from './nagad.adapter.js';
import type { ProviderAdapter, ProviderId } from './provider.interface.js';
import { RocketAdapter } from './rocket.adapter.js';
import { notFound } from '../../../core/errors/AppError.js';

/**
 * Resolves the correct adapter for a given provider.
 *
 * All adapters are instantiated once and reused for the lifetime of the
 * process — see SYSTEM_ARCHITECTURE.md §3.
 */
const adapters: Record<ProviderId, ProviderAdapter> = {
  bkash: new BkashAdapter(),
  nagad: new NagadAdapter(),
  rocket: new RocketAdapter(),
};

export function getAdapter(providerId: ProviderId): ProviderAdapter {
  const adapter = adapters[providerId];
  if (!adapter) {
    throw notFound('PROVIDER_UNKNOWN', `No adapter registered for provider: ${providerId}`);
  }
  return adapter;
}

export function listProviders(): ProviderId[] {
  return Object.keys(adapters) as ProviderId[];
}
