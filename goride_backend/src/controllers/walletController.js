const { supabase } = require('../config/supabase');

class WalletController {
  async getBalance(req, res, next) {
    try {
      const { userId } = req.query;
      const { data, error } = await supabase
        .from('profiles')
        .select('wallet_balance')
        .eq('id', userId)
        .single();

      if (error) throw error;
      res.json(data);
    } catch (error) {
      next(error);
    }
  }

  async getTransactionHistory(req, res, next) {
    try {
      const { userId } = req.query;
      const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      res.json(data);
    } catch (error) {
      next(error);
    }
  }

  async topup(req, res, next) {
    try {
      const { userId, amount } = req.body;
      
      const { data, error } = await supabase.rpc('topup_wallet', {
        p_user_id: userId,
        p_amount: amount
      });

      if (error) throw error;
      res.json({ message: 'Top-up successful', balance: data });
    } catch (error) {
      next(error);
    }
  }

  async payout(req, res, next) {
    try {
      const { userId, amount } = req.body;

      if (amount < 500) {
        return res.status(400).json({ message: 'Minimum payout amount is Rs. 500' });
      }

      const { data, error } = await supabase.rpc('request_payout', {
        p_user_id: userId,
        p_amount: amount
      });

      if (error) throw error;
      res.json({ message: 'Payout request processed', balance: data });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new WalletController();
