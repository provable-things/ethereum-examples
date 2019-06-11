### "Relaxed" commitment hash Random Example

The goal of this example is to showcase how to override the __`oraclize_newRandomDSQuery`__ function that appears in the Provable API so that the commitment hash requirements are relaxed making the proof more resilient to block re-organizations.

The default example __`../randomExample.sol`__ has the highest security guarantees, but the proof will fail at any re-org. This relaxed example is expected to work successfully even with a block re-org up to four blocks deep, which re-orgs occur much less frequently.
